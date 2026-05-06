Purpose: End-to-end implementation workflow using Nazgul agents.

Instructions (for Copilot agent use):
1. Run `witch-king` first to inspect the workspace and request a plan.
2. `witch-king` will instruct `khamul` (PO) to produce a proposed assignment list for the work.
3. `witch-king` must review and approve `khamul`'s proposals before any assignments are dispatched.
4. After approval, dispatch backend tasks to `morgul` and frontend tasks to `akhorahil` (frontend implementer).
5. If a proposed change is flagged as `BreakingChange: true` or has `DataLossRisk` medium/high, stop and escalate to the user for explicit approval — do not proceed even with `witch-king` approval.
5. Use `fellbeast` for final review and validation before declaring success; `fellbeast` should execute the provided validation commands and include outputs in the report.
6. Enforce the minimal-change principle; prefer smallest correct edits.
7. For any implementation, list changed files and explain each change; provide unified diffs or file edit snippets.
8. When assigning tasks, include the exact `Validation` commands the reviewer should run and the expected success indicators (exit codes, text matches).
8. Report validation commands run and results honestly; do not claim success without validation.

Assignment/implementation checklist (required for every assignment):
 - ProposedBy: `khamul`
 - ApprovedBy: `witch-king` (or user if escalated)
 - BreakingChange: true/false
 - FilesChanged: list
 - Patch: unified diff or file edits
 - ValidationCommands: list
 - ExpectedSuccess: one-line expected result per command
 - RollbackPlan: one-line or N/A
