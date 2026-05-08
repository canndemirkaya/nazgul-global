# Usage

Open Copilot Chat in VS Code and select an agent from the agent dropdown.

Agent roles:
- `witch-king`: planning, orchestration, and final acceptance (inspect-only).
- `khamul`: Product Owner — analyzes requests, produces proposals, defines acceptance criteria.
- `morgul`: backend and API implementation.
- `akhorahil`: frontend and UI implementation.
- `fellbeast`: review, testing, and release gatekeeper.

Recommended workflow:
1. Run `witch-king` to inspect the workspace and produce a minimal plan.
2. `witch-king` instructs `khamul` (PO) to produce a proposed assignment list.
3. `witch-king` reviews and approves `khamul`'s proposals.
4. Run `morgul` for backend tasks and `akhorahil` for frontend tasks.
5. Run `fellbeast` for final validation and release readiness.
