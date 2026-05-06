Khamul (PO) usage guide

Purpose: how `khamul` should use the proposal template and submit proposals for `witch-king` review.

Steps:
1. Create a proposal using `prompts/khamul-proposal.template.md` or `prompts/khamul-proposal-examples.md` as examples.
2. Ensure `BreakingChange` and `DataLossRisk` fields are accurate. If `BreakingChange=true` or `DataLossRisk` is `medium`/`high`, add the `ESCALATE_TO_USER` tag in the proposal.
3. Attach a machine-applicable unified diff (preferred) in the `Patch` field.
4. Run local validation commands you include in `Validation` to ensure they pass on your machine.
5. Submit the proposal by saving it to `promposals/` (or sending it to `witch-king` via the agent workflow). Use the `scripts/trigger_witchking_approval.ps1` script to request `witch-king` review.

Important policy:
- Do NOT commit/push/revert any changes without explicit user approval. Produce patches only; wait for `witch-king` and user approval before VCS operations.

Example command to request review (from repo root):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\trigger_witchking_approval.ps1 -ProposalFile prompts\khamul-proposal-examples.md
```

The script will produce `scripts/witchking_approval_report.txt` summarizing approvals and escalations.
