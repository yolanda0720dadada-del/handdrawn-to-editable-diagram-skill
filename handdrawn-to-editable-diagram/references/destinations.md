# Destination routing

Read only the section for the chosen destination.

## Feishu/Lark whiteboard

Read [feishu-whiteboard.md](feishu-whiteboard.md). Use this skill's independent SVG-to-Feishu pipeline and scripts. Require the user's own Feishu authorization and an explicit document target or `--new-doc`. Keep every semantic item as a native editable shape, text object, or connector. Return the Feishu document link and rendered preview.

## Figma or FigJam

Require a Figma write capability, not merely image upload. Accept a supported Figma MCP, connector, plugin bridge, or an operator-provided API service. Use FigJam for collaborative diagrams and Figma Design for polished report graphics. Create native text, vector/shape, frame/group, and connector nodes where the environment supports them. If the environment can only upload a bitmap, fall back to editable SVG instead.

## PowerPoint

Require a presentation runtime capable of writing `.pptx`. Create a slide whose shapes, connectors, and text boxes remain editable. Use native presentation shapes whenever possible. Avoid inserting a single flattened diagram image. Provide the `.pptx` deliverable and a rendered preview.

## Editable SVG

Create standards-compliant SVG with separate `<text>`, shape, group, and connector elements. Include stable IDs derived from Diagram IR IDs, a `viewBox`, accessible title/description, and arrow markers. Do not outline text. Verify the SVG by rendering it to PNG and inspecting the result. Return both SVG and preview PNG.

## Mermaid or diagrams.net

Offer Mermaid only when text-based editing and version control matter more than visual polish. Use diagrams.net XML only when the user explicitly requests draw.io/diagrams.net or when its offline editor is a better fit. In both cases, preserve Diagram IR IDs where possible.

## Fallback

If a requested connector or destination capability is unavailable, do not silently flatten the result. Offer editable SVG as the portable fallback and explain the limitation in one sentence.
