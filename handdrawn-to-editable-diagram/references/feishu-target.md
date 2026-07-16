# Feishu destination configuration

Resolve the target in this order:

1. `--doc <token-or-url>` supplied for the current request.
2. `HANDDRAWN_DIAGRAM_FEISHU_DOC` set by the user or deployment.
3. `--new-doc` when the user requests a separate document.

If none is available, ask the user for a Feishu document URL/token or permission to create a new document. Never embed a personal token, URL, tenant, or account in a shared skill.

When appending, create a new `<h2>` title followed by a blank whiteboard block. Write the diagram into the newly returned whiteboard `block_token`. Never overwrite or reuse an earlier whiteboard token unless the user explicitly requests an in-place update and supplies the target whiteboard token.
