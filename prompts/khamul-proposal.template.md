Purpose: Template for `khamul` (PO) proposals. Fill every field; be explicit about breaking changes and validation commands.

Template fields:

- Title: A single-line summary.
- Summary: One paragraph describing intent and user-visible outcome.
- Impact: List the subsystems and files likely affected (e.g., backend: src/ServiceX, db/migrations; frontend: web/src/components).
- BreakingChange: true/false
  - If true, describe why this is breaking and list migration/compatibility considerations.
- DataLossRisk: none / low / medium / high
  - If medium/high, include mitigation steps and immediate escalation recommendation.
- PreferredImplementer: `morgul` / `akhorahil` / `either` (provide rationale).
- Options: (optional) If multiple approaches exist, list 2-3 options with pros/cons and estimated effort.
- Patch: Provide a machine-applicable unified diff (preferred) or exact file edits. Use standard `diff -u` format or a patch block.
- Validation: Exact commands to run and the expected success criteria (string matches, exit codes, etc.). Example:
  - `dotnet test ./src/Service.Tests` -> exit code 0 and 12 tests passed
  - `powershell -File ./scripts/check_agents.ps1` -> lists agents including witch-king
- EstimatedEffort: e.g., 1h, 4h, 1d
- RollbackPlan: brief description or `N/A` if not applicable.

Rules and escalation:
- If `BreakingChange` = true OR `DataLossRisk` is `medium`/`high`, do NOT auto-assign; add the tag `ESCALATE_TO_USER` and send to `witch-king` for review. `witch-king` must escalate to the user before proceeding.
- Include exact file diffs — avoid vague descriptions. Machine-readable patches speed approval and implementation.

Example (short):
- Title: Add status endpoint for Service Z
- Summary: Adds GET /api/z/status returning {status: 'ok'} used by monitoring.
- Impact: backend: src/ServiceZ/Controllers/StatusController.cs; tests: src/ServiceZ.Tests/StatusTests.cs
- BreakingChange: false
- DataLossRisk: none
- PreferredImplementer: morgul
- Patch: (unified diff block)
- Validation:
  - `dotnet test ./src/ServiceZ.Tests` -> exit code 0
  - `curl -s http://localhost:5000/api/z/status` -> `{"status":"ok"}`
- EstimatedEffort: 2h
- RollbackPlan: revert commit
