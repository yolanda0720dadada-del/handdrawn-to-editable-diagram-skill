# Independent Feishu whiteboard pipeline

Use this workflow directly. Do not load or invoke any other whiteboard-design skill.

## Goal

Translate Diagram IR into a Feishu/Lark whiteboard where users can separately select and edit text, nodes, and connectors. A rendered PNG is for verification only; it is never the board payload.

## Prerequisites

Run `scripts/preflight.sh`. Require Node 20+, `npx`, authenticated `lark-cli`, and Python 3. If authentication fails, ask the user to complete `lark-cli config init` and `lark-cli auth login`, then stop.

## SVG as the editable transport

Compose an SVG about 1600–1700 logical pixels wide with content-defined height. Use stable IDs matching Diagram IR IDs.

Allowed editable primitives:

- `<rect>` with optional `rx`
- `<circle>` and `<ellipse>`
- `<line>` and right-angled `<polyline>`
- `<text>` and `<tspan>`
- `<g>` for logical grouping
- `<marker>` only to signal native arrowheads

Hard constraints:

- Keep every label in `<text>`; never convert text to paths.
- Never use `<image>`, `<foreignObject>`, gradients, filters, masks, clipping, patterns, or opacity.
- Never use polygons or freeform paths as structural nodes. A `<path>` is allowed only inside an arrow marker definition.
- Put `marker-end` on the connector itself. Never draw arrowheads as separate triangles.
- Use straight or orthogonal connectors. Route around nodes and labels.
- Give every semantic shape, text, and connector a unique stable `id`.
- Do not set `font-family`; Feishu controls the board font.
- Wrap long text with `<tspan>` and leave generous padding.

## Build and verify

1. Create `diagram.svg` from Diagram IR.
2. Run `python3 scripts/validate_editable_svg.py diagram.svg`. Fix every error before continuing.
3. Render and check locally:

   ```bash
   npx -y @larksuite/whiteboard-cli@^0.2.11 -i diagram.svg -o diagram.png -f svg
   npx -y @larksuite/whiteboard-cli@^0.2.11 -i diagram.svg -f svg --check
   ```

4. View `diagram.png`. Check missing text, overflow, clipping, collisions, connector crossings, reversed arrows, and inconsistent hierarchy. Make targeted SVG edits and repeat.
5. Read [feishu-target.md](feishu-target.md). Run `scripts/create_feishu_board.sh --svg diagram.svg --title "<title>" --output-dir <dir> --doc <token-or-url>`, or set `HANDDRAWN_DIAGRAM_FEISHU_DOC`. Use `--new-doc` only when the user explicitly asks for a separate document.
6. View the queried live preview. Compare it with Diagram IR, not merely with the local PNG.
7. Confirm editability from the update result or raw whiteboard query: text count, shape count, and connector count should be non-zero and close to the validated SVG manifest.

## Semantic QA checklist

- Every observed node exists once.
- Every edge has the correct source, target, and direction.
- Groups/lanes preserve membership.
- No uncertain OCR has been silently presented as certain.
- Layout follows the intended reading direction.
- The original sketch may be attached beside the board only when useful; it must not replace editable content.

## Delivery

Return the Feishu document link and the live preview image. List only material OCR assumptions that remain. Offer direct text or relationship corrections; do not offer a palette menu by default.
