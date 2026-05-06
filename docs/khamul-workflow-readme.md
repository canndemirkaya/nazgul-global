Khamul — Proposal workflow (quick README)

Purpose
- Quick guide for `khamul` to create machine-ready proposals and request Witch‑King approval.

Proposal format
- Use a YAML frontmatter block at the top of each proposal section. Example:

---
Title: Add status endpoint for Service Z
Summary: Adds GET /api/z/status returning {"status":"ok"} for monitoring.
Impact: backend: src/ServiceZ/Controllers/StatusController.cs
BreakingChange: false
DataLossRisk: none
PreferredImplementer: morgul
Patch: |
  (unified diff here)
Validation: |
  dotnet test ./src/ServiceZ.Tests
EstimatedEffort: 2h
---

How to submit
1. Create a proposal file (Markdown with one or more frontmatter proposal sections) under `prompts/` or any path you prefer.
2. Ensure `BreakingChange` and `DataLossRisk` are accurate; if `BreakingChange=true` or `DataLossRisk` is `medium`/`high`, include `ESCALATE_TO_USER` in your notes.
3. Run the Witch‑King approval trigger locally to get a quick decision report:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\trigger_witchking_approval.ps1 -ProposalFile "prompts\your-proposal.md"
```

4. Inspect `scripts/witchking_approval_report.txt`. If the report marks your proposal as `ESCALATE`, stop and prepare runbooks, rollback plans, and request explicit user approval.
5. For non-ESCLATE proposals, `witch-king` will indicate the preferred implementer; produce the machine-applicable patch and wait for `witch-king` or the user to approve applying commits.

Important policy
- Agents must NOT perform `git commit`/`git push`/`git revert` without explicit user approval. Always provide a unified diff or patch and request approval before VCS operations.

Support
- If you want, I can convert existing example proposals in `prompts/khamul-proposal-examples.md` into properly formatted frontmatter blocks.
