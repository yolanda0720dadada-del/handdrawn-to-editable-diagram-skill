#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --svg FILE --title TITLE --output-dir DIR [--doc TOKEN_OR_URL | --new-doc] [--dry-run]"
}

svg=""; title=""; output_dir=""; dry_run=0; new_doc=0
doc_target="${HANDDRAWN_DIAGRAM_FEISHU_DOC:-}"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --svg) svg="$2"; shift 2 ;;
    --title) title="$2"; shift 2 ;;
    --output-dir) output_dir="$2"; shift 2 ;;
    --doc) doc_target="$2"; shift 2 ;;
    --new-doc) new_doc=1; shift ;;
    --dry-run) dry_run=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done

[ -n "$svg" ] && [ -f "$svg" ] || { echo "ERROR: --svg must be an existing file" >&2; exit 2; }
[ -n "$title" ] || { echo "ERROR: --title is required" >&2; exit 2; }
[ -n "$output_dir" ] || { echo "ERROR: --output-dir is required" >&2; exit 2; }
[ "$new_doc" -eq 1 ] || [ -n "$doc_target" ] || { echo "ERROR: provide --doc, set HANDDRAWN_DIAGRAM_FEISHU_DOC, or use --new-doc" >&2; exit 2; }

script_dir="$(cd "$(dirname "$0")" && pwd)"
"$script_dir/preflight.sh" feishu
python3 "$script_dir/validate_editable_svg.py" "$svg"
mkdir -p "$output_dir"
export npm_config_cache="${npm_config_cache:-${TMPDIR:-/tmp}/handdrawn-diagram-npm-cache}"
mkdir -p "$npm_config_cache"

if [ "$dry_run" -eq 1 ]; then
  echo "DRY RUN OK: SVG is structurally editable and Feishu prerequisites are available"
  exit 0
fi

npx -y @larksuite/whiteboard-cli@^0.2.11 -i "$svg" -o "$output_dir/local-preview.png" -f svg
npx -y @larksuite/whiteboard-cli@^0.2.11 -i "$svg" -f svg --check

content="$(python3 - "$title" <<'PY'
import html, sys
print(f'<h2>{html.escape(sys.argv[1])}</h2><whiteboard type="blank"></whiteboard>')
PY
)"

if [ "$new_doc" -eq 1 ]; then
  create_content="$(python3 - "$title" <<'PY'
import html, sys
value = html.escape(sys.argv[1])
print(f'<title>{value}</title><h2>{value}</h2><whiteboard type="blank"></whiteboard>')
PY
)"
  lark-cli docs +create --api-version v2 --content "$create_content" --as user > "$output_dir/doc-write.json"
else
  lark-cli docs +update --api-version v2 --doc "$doc_target" --command append --content "$content" --as user > "$output_dir/doc-write.json"
fi

parsed_tokens="$(python3 - "$output_dir/doc-write.json" "$doc_target" "$new_doc" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
found = {"whiteboard": None, "url": None}
def walk(value, parent=None):
    if isinstance(value, dict):
        for key, child in value.items():
            low = key.lower()
            if low in {"block_token", "whiteboard_token"} and isinstance(child, str) and not found["whiteboard"]:
                found["whiteboard"] = child
            if low in {"url", "document_url", "doc_url"} and isinstance(child, str) and child.startswith("http") and not found["url"]:
                found["url"] = child
            walk(child, value)
    elif isinstance(value, list):
        for child in value: walk(child, parent)
walk(data)
if not found["url"] and sys.argv[3] == "0":
    target = sys.argv[2]
    found["url"] = target if target.startswith("http") else "https://my.feishu.cn/docx/" + target
print((found["whiteboard"] or "") + "|" + (found["url"] or ""))
PY
)"
whiteboard_token="${parsed_tokens%%|*}"
doc_url="${parsed_tokens#*|}"

[ -n "$whiteboard_token" ] || { echo "ERROR: could not find whiteboard token in doc-create.json" >&2; exit 1; }

npx -y @larksuite/whiteboard-cli@^0.2.11 -i "$svg" --to openapi --format json | \
  lark-cli whiteboard +update --whiteboard-token "$whiteboard_token" --source - --input_format raw \
  --idempotent-token "handdrawn-$(date +%s)" --overwrite --as user > "$output_dir/board-update.json"

lark-cli whiteboard +query --whiteboard-token "$whiteboard_token" --output_as raw --output "$output_dir" --overwrite --as user > "$output_dir/board-raw-query.json"
raw_path="$output_dir/whiteboard_${whiteboard_token}.json"
[ -f "$raw_path" ] || { echo "ERROR: raw Feishu board query did not produce nodes" >&2; exit 1; }
python3 - "$raw_path" <<'PY'
import collections, json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
counts = collections.Counter(node.get("type", "unknown") for node in data.get("nodes", []))
required = ["text_shape", "composite_shape", "connector"]
missing = [kind for kind in required if counts[kind] == 0]
if missing:
    raise SystemExit("ERROR: Feishu board is missing editable node types: " + ", ".join(missing))
print("FEISHU_EDITABLE_MANIFEST=" + ",".join(f"{k}:{v}" for k, v in sorted(counts.items())))
PY
lark-cli whiteboard +query --whiteboard-token "$whiteboard_token" --output_as image --output "$output_dir" --overwrite --as user > "$output_dir/board-query.json"

printf 'WHITEBOARD_TOKEN=%s\n' "$whiteboard_token"
printf 'DOC_URL=%s\n' "$doc_url"
printf 'OUTPUT_DIR=%s\n' "$output_dir"
