---
name: handdrawn-to-editable-diagram
description: Convert any uploaded or local photo/scan of a hand-drawn sketch into a logically faithful, editable computer-drawn diagram or reporting visual. Use when users ask to clean up, redraw, digitize, structure, or convert handwritten diagrams, whiteboard photos, workflows, architectures, mind maps, relationship maps, timelines, swimlanes, organization charts, or rough presentation graphics, especially when the result must be created as native editable objects in a Feishu/Lark whiteboard, Figma/FigJam, PowerPoint, editable SVG, or another supported destination.
---

# Hand-drawn sketch to editable diagram

Turn the sketch into a general, tool-neutral diagram model first. Treat examples only as sample content; never encode their domain, labels, layout, or business logic as a fixed template.

## Core workflow

1. Inspect every supplied image in original orientation and at sufficient detail. Correct for rotation, perspective, shadows, and partial cropping in interpretation; do not modify the source bitmap unless requested.
2. Classify the visual intent. Consider flowchart, swimlane/process map, system architecture, data flow, organization chart, relationship/network map, mind map, timeline, matrix, layered model, funnel, table-like comparison, and reporting infographic. Use a hybrid when one type does not capture the sketch.
3. Select a generation mode using the rules in **Generation modes** below. Do this before asking for a fuller image or resolving every handwritten detail.
4. Build the tool-neutral Diagram IR described in [references/diagram-ir.md](references/diagram-ir.md). Separate observed content, user-stated intent, and inferred structure. Preserve illegible text as an uncertainty instead of inventing it.
5. Plan the layout from the Diagram IR. Preserve intentional order, grouping, direction, emphasis, and many-to-many relationships. Treat topology and labels as fixed in faithful mode; in intent-enhanced mode, reorganize presentation only to serve the user's stated communication goal.
6. Briefly show the proposed interpretation when any material ambiguity remains. Include the detected diagram type, reading direction, main groups, and only the uncertainties that could change meaning. Do not burden the user with cosmetic choices.
7. If the destination is not already specified, offer a short destination choice and wait:
   - Feishu/Lark whiteboard — quickest collaborative editing for business teams.
   - Figma/FigJam — strongest professional design control.
   - PowerPoint — best for editable shapes inside a presentation.
   - Editable SVG — portable, local, and importable into many tools.
   Recommend one based on the user's context, but keep all available options selectable.
8. Read `capabilities.yaml`, then run `scripts/preflight.sh <destination>` before rendering. Install ordinary local dependencies only when the environment and user policy permit it. Never bypass account authorization. If the selected platform cannot be written from the current agent, explain the missing capability in one sentence and automatically offer editable SVG as the fallback.
9. Render the selected destination by following [references/destinations.md](references/destinations.md). For Feishu, use this skill's own [references/feishu-whiteboard.md](references/feishu-whiteboard.md) and scripts; do not invoke another whiteboard-design skill.
10. Verify two things independently: semantic fidelity against the Diagram IR, and editability of text, nodes, groups, and connectors. Correct missing, reversed, or crossed connections before delivery.
11. Provide the actual link/file plus a preview when supported. Do not stop at Mermaid code, a prompt, or a flattened image unless the user explicitly requests only a draft.

## Generation modes

Choose exactly one mode for each output.

### Intent-enhanced

Use this mode when the user wants a clearer communication artifact, or when they have not explicitly requested an exact redraw. If the answers are not already present in the conversation, ask these two questions together:

1. 这张图想表达的中心思想是什么？
2. 希望看图的人理解、记住或采取什么行动？

Add one short escape hatch: `如果只想按原图重绘，直接说“按原图画”。`

Fuse the answers with the visible sketch. Keep observed facts and relationships traceable, but allow clearer grouping, headings, callouts, reading order, and emphasis. Add or rewrite content only when it is supported by the user's answers. Mark semantic additions as `observed: false` with `source: user_intent`; never present an unsupported inference as a fact.

### Faithful redraw

Use this mode whenever the user says `按原图画`, `照着画`, `不要发挥`, `忠实重绘`, or an equivalent instruction. Reproduce the visible text, nodes, groups, order, and connections without supplementing the business logic. Improve only alignment, spacing, typography, connector routing, and visual consistency.

A cropped or partial image defines the current source scope; it is not by itself a reason to request a complete image. Ask for another image only when a missing portion prevents drawing a visible node or connector that the user explicitly expects to include. If non-critical text is illegible, keep a clearly marked placeholder such as `待确认` rather than blocking the redraw.

## Interpretation rules

- Use the image as evidence, not as a literal layout specification.
- Preserve meaning before aesthetics. Never silently delete a node or merge distinct branches merely to simplify the picture.
- Model arrows with explicit source, target, direction, label, and routing intent.
- Model containers, brackets, lanes, and surrounding boxes as groups or regions rather than background decoration.
- Distinguish text labels, notes, titles, legends, and callouts.
- Mark uncertain OCR with confidence and alternatives. Ask only when the ambiguity affects structure or business meaning within the selected source scope.
- Do not treat cropping as missing requirements. First determine whether the user wants intent-enhanced communication or a faithful redraw of what is currently visible.
- When several sketches are supplied, determine whether they are pages of one diagram, alternatives, or separate outputs. Infer this when obvious; otherwise ask one concise question.
- When the user supplies an expected result, learn its visual language and level of polish, but keep the underlying workflow general-purpose.

## Priority order

Use this order when requirements compete:

1. Correct text and relationships.
2. Native editability in the selected destination.
3. Clear reading order and low connector crossing.
4. Visual consistency.
5. Decorative polish.

## Visual direction

Default to one business-minimal system: neutral background, dark text, one primary accent, optional secondary accent, strong hierarchy, generous whitespace, consistent corners, and orthogonal connectors. Read [references/style-system.md](references/style-system.md) before rendering unless the user provides a visual system.

Avoid decorative gradients, excessive shadows, novelty icons, and dense color coding. Use color to explain categories, state, or paths—not merely to decorate.

## User control

- Let the user correct recognized text and relationships before rendering when confidence is low.
- Let the user override the detected diagram type.
- Let the user choose the destination. Ask about style only when the user explicitly cares about branding or visual mood; otherwise use the default system.
- Preserve the original image alongside the structured result when the destination permits it.
- Make regeneration idempotent: keep the Diagram IR as the source of truth so a user can switch destinations or styles without reinterpreting the sketch from scratch.

## Portability and dependencies

Read [references/requirements.md](references/requirements.md) when installing or sharing this skill. Use the machine-readable `capabilities.yaml` to decide which adapters are available. Platform adapters require the user's own account and authorization; the core interpretation, Diagram IR, and editable SVG path remain platform-independent.

For Feishu, append to `HANDDRAWN_DIAGRAM_FEISHU_DOC` or a document explicitly supplied by the user. Never ship a personal document token in a public package. For Figma, require a connector, MCP server, plugin bridge, or service that can write native Figma nodes; a prompt alone cannot modify a cloud file.

## Completion standard

Finish only when the output is visually coherent, faithful to the sketch's logic, and editable in the selected destination. State any remaining uncertain text or unsupported destination behavior plainly.
