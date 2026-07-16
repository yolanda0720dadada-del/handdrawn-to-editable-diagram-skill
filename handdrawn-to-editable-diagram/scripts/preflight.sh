#!/usr/bin/env bash
set -euo pipefail

fail() { printf 'ERROR: %s\n' "$1" >&2; exit 1; }
has() { command -v "$1" >/dev/null 2>&1; }

destination="${1:-all}"
case "$destination" in
  svg)
    has python3 || fail "Python 3 is required for SVG validation"
    printf 'OK destination=svg python=%s\n' "$(python3 --version 2>&1)"
    ;;
  feishu)
    has node || fail "Node.js 20+ is required"
    has npx || fail "npx is required"
    has python3 || fail "Python 3 is required"
    has lark-cli || fail "lark-cli is required; install @larksuite/cli"
    node_major="$(node -p 'Number(process.versions.node.split(".")[0])')"
    [ "$node_major" -ge 20 ] || fail "Node.js 20 or newer is required"
    lark-cli auth login --help >/dev/null 2>&1 || fail "run lark-cli config init and lark-cli auth login"
    printf 'OK destination=feishu node=%s lark-cli=%s\n' "$(node -v)" "$(lark-cli --version 2>/dev/null | head -n 1)"
    ;;
  figma)
    if [ "${FIGMA_WRITE_CONNECTOR:-}" = "1" ] || [ "${FIGMA_MCP_AVAILABLE:-}" = "1" ]; then
      printf 'OK destination=figma write-capability=declared\n'
    else
      fail "a Figma write connector/MCP/plugin bridge is required; set FIGMA_WRITE_CONNECTOR=1 after configuring it"
    fi
    ;;
  powerpoint)
    if [ "${PRESENTATION_RUNTIME_AVAILABLE:-}" = "1" ]; then
      printf 'OK destination=powerpoint runtime=declared\n'
    else
      fail "an editable PowerPoint generation runtime is required; set PRESENTATION_RUNTIME_AVAILABLE=1 after configuring it"
    fi
    ;;
  all)
    "$0" svg
    for optional in feishu figma powerpoint; do
      if "$0" "$optional" >/dev/null 2>&1; then
        printf 'AVAILABLE %s\n' "$optional"
      else
        printf 'UNAVAILABLE %s\n' "$optional"
      fi
    done
    ;;
  *) fail "unknown destination: $destination (use svg, feishu, figma, powerpoint, or all)" ;;
esac
