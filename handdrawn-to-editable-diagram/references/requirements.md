# Runtime requirements

Check only the destination selected by the user. Run `scripts/preflight.sh <destination>` and interpret failures as actionable missing capabilities.

| Destination | Required capability | User action that cannot be bypassed | Fallback |
|---|---|---|---|
| Editable SVG | Vision input, local file access, Python 3 validation | None | — |
| Feishu/Lark | Node.js 20+, `npx`, Python 3, `lark-cli`, whiteboard conversion package | Complete Feishu OAuth/login and provide/create a target document | SVG |
| Figma/FigJam | A write-enabled Figma connector, MCP server, plugin bridge, or service | Authorize the target Figma account/workspace | SVG |
| PowerPoint | Runtime that creates native `.pptx` shapes and text | Environment-dependent | SVG |

Ordinary packages may be installed by the agent only when its environment policy and the user allow it. Account authorization must always be completed by the user. A browser-only chat without file/tool access can still produce Diagram IR or SVG source text, but cannot claim that it updated a cloud document.

## Environment hints

- Codex with Figma and Feishu tooling: use native connectors or the bundled Feishu scripts.
- Claude Code, Cursor, and other local agents: use the common core; configure equivalent MCP/connectors for cloud destinations.
- Restricted web chat: generate editable SVG and let the user import it.
- Custom applications: expose Diagram IR as the stable contract and implement platform adapters behind authenticated services.
