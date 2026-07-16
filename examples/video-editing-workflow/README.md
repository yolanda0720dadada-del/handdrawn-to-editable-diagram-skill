# Reference example: video editing workflow

This confidentiality-safe example demonstrates **faithful redraw** mode on a fictional hand-drawn video-editing workflow. It contains no real company, client, campaign, channel, or operational data.

## Input / Output comparison

| Input: uploaded hand-drawn sketch | Output: editable SVG (rendered preview) |
|---|---|
| ![Input: hand-drawn source](source-sketch.png) | [![Rendered preview of the generated SVG](preview.png)](editable-diagram.svg) |

- **Input file:** [`source-sketch.png`](source-sketch.png)
- **Output file:** [`editable-diagram.svg`](editable-diagram.svg)
- Click the Output preview above to open the actual SVG.

The source contains two sections with the same structural complexity as a real working diagram:

- **素材整理**: shooting material branches into main footage, B-roll, and audio, then maps one-to-one into three media bins.
- **剪辑制作**: two editors connect to rough cut, fine cut, and color grading tasks; all three tasks feed both horizontal and vertical final outputs through a many-to-many relationship.

## Processing decisions

- `generation_mode`: `faithful`
- `source_scope`: `complete`
- Reading direction: left to right
- Preserve every visible source, task, output, and connection.
- Improve alignment, spacing, typography, and connector routing only.
- Do not add production stages or deliverables that are not present in the sketch.

The normalized interpretation is stored in [`diagram-ir.json`](diagram-ir.json).

## Output details

- `editable-diagram.svg` is the actual generated result. It keeps text, shapes, groups, and connectors separately editable.
- [`preview.png`](preview.png) is only a rendered verification image; it is not the primary output.
- The SVG can be written as editable objects to Feishu/Lark and imported into Figma as editable text and vector layers. Cloud account links and personal document tokens are intentionally excluded from this public example.
