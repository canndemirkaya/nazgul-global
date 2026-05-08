# Copilot Agent Instructions

Agents should check this file first for repository-specific policies and context.

Key points:
- Follow roles defined in `agents/*.agent.md` and `agents/*.agent.yaml`.
- Do not perform VCS operations (`git commit`, `git push`, `git revert`) without explicit user approval.
- Use `promposals/` as the canonical folder for submitting proposals to `witch-king` (if present).
- Run `scripts/validate_frontmatter.ps1` and the test suite before proposing patches.

If you need to raise an escalation, add `ESCALATE_TO_USER` in the proposal frontmatter and use `scripts/trigger_witchking_approval.ps1`.
