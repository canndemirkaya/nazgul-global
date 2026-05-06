# Nazgul — Global Copilot Agent Pack

Nazgul is a global, user-level Copilot custom agent pack intended to be reused across different VS Code workspaces. It does not modify project code by default and is designed to be installed into the user's Copilot folder.

Key points:
- This folder is a setup/export package for the Nazgul agents.
- Do not treat this as an application repository.
- Install globally to make agents available in VS Code for all workspaces.

Workflow summary (current defaults):

- `witch-king` — Lead Engineer and orchestrator. Inspects workspace, requests PO proposals, approves assignments, and gives final acceptance.
- `khamul` — Product Owner (PO). Produces proposed assignment lists (who, what, exact patches, validation commands) and sends proposals to `witch-king` for approval.
- `morgul` — Backend implementer (APIs, DB, integrations). Acts only on `khamul`-created proposals after `witch-king` approval.
- `akhorahil` — Frontend implementer (React/TypeScript, UI). Acts only on `khamul`-created proposals after `witch-king` approval.
- `fellbeast` — Reviewer and validator. Executes validation commands and returns `approve`/`request changes` verdicts to `witch-king`.

Notes:
- Agents now follow a strict propose-and-approve flow: `khamul` proposes, `witch-king` approves, implementers execute, `fellbeast` validates, `witch-king` accepts.
- Install scripts place agent files and prompts under `%USERPROFILE%\.copilot\agents` and `%USERPROFILE%\.copilot\nazgul\prompts` respectively.

Skills and docs:
- This pack includes detailed skill descriptions for each agent under `docs/skills/`.
- The installer copies the `docs/` tree (including `docs/skills`) to `%USERPROFILE%\.copilot\nazgul\docs` so you can read agent skills and guidance from there.

Installation (Windows):
  .\scripts\install-global-nazgul.ps1

Uninstall (Windows):
  .\scripts\uninstall-global-nazgul.ps1

After installing, restart or reload VS Code, open Copilot Chat, and pick an agent from the dropdown.
