# Agent Responsibility Matrix

Overview of the orchestrated workflow:

- `witch-king` — Lead Engineer / Orchestrator
	- Inspect the workspace, produce a high-level plan, and request a proposed assignment list from the Product Owner (PO).
	- Review and approve the PO's proposed assignments before dispatching work.
	- Approve final acceptance after `fellbeast` review and deliver the final report to the user.

- `khamul` — Product Owner (PO)
	- Analyze `witch-king`'s requested work and produce a proposed assignment list (who, what, exact patches, validation commands).
	- Send proposals to `witch-king` for review/approval; do not assign work directly until approved.

- `morgul` — Backend implementer
	- Responsible for backend, API, database, and integration work (including .NET/C# when detected).
	- Only act on tasks explicitly assigned by `khamul` (PO) and approved by `witch-king`.

- `akhorahil` — Frontend implementer
	- Responsible for frontend, React/TypeScript, and UI/API client integration.
	- Only act on tasks explicitly assigned by `khamul` (PO) and approved by `witch-king`.

- `fellbeast` — Reviewer & Validator
	- Run validation commands, review changes for quality/security/perf, and return an `approve` or `request changes` verdict with captured outputs.

Delegation rules (summary):
- All implementation assignments must be proposed by `khamul` and explicitly approved by `witch-king` before dispatch.
- Implementers (`morgul`, `akhorahil`) must provide machine-applicable patches and exact validation commands when completing work.
- `fellbeast` executes validation commands and includes their outputs in the review report; final acceptance is given by `witch-king`.

Skills and documentation:
- Agent skill definitions (detailed agent responsibilities and allowed tools) are available under `docs/skills/` inside this pack. Each skill file contains invocation guidance and expected outputs.
- After installation, skills and docs are copied to the user's Copilot docs path: `%USERPROFILE%\.copilot\nazgul\docs\skills`.

See also: [README.md](../README.md) for install/uninstall instructions.
