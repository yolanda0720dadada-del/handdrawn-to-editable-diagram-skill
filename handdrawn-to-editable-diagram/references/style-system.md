# Functional business-minimal style system

This is a fixed default, not a palette catalogue. Use it unless the user supplies brand rules.

## Defaults

- Canvas: warm white or very light neutral (`#FAFBFA` / `#F5F7F6`).
- Primary text: near-black slate (`#17202A`).
- Secondary text: neutral gray (`#6F7885`).
- Borders/connectors: soft gray (`#CBD3CF`), 1–1.5 px at final scale.
- Primary accent: restrained green (`#1F7A5C`) or the user's brand color.
- Secondary accent: blue (`#3D8FD1`) only when a second semantic category requires it.
- Cards: white fill, 8–12 px corner radius, minimal shadow or no shadow.

## Layout

- Establish one dominant reading direction.
- Use a consistent spacing unit and at least 1.5× node height between major groups.
- Align repeated peers to a shared grid.
- Keep labels close to their object and prevent connectors from crossing text.
- Prefer straight or orthogonal connectors. Use curves only when the destination preserves them as editable connectors.
- Reserve icons for recognizable roles; do not use icons as decoration.

## Typography

- Use a modern sans-serif supporting the content language.
- Use 3–4 text levels at most: title, group heading, node label, annotation.
- Keep body labels readable at the expected presentation/export size.
- Use weight and spacing before adding more colors.

## Semantic use of style

- Color indicates category, state, ownership, or path—never decoration alone.
- Shape indicates node role only when the distinction matters: process rectangle, decision diamond when supported, actor/system card, container/lane.
- Line style indicates relationship semantics: solid for primary flow, dashed only for reference/dependency when supported.
- Never change topology to improve appearance.

## Report graphics

For presentation-oriented visuals, add a concise title, optional one-line takeaway, and a small legend only when required. Keep the core diagram dominant. Do not turn every diagram into a dashboard.
