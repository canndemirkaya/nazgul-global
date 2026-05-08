# Nazgul Global — Copilot Agent Pack

A curated pack of Copilot agent definitions, prompts and installer scripts to help teams run a safe, review-driven automation workflow.

Quick overview
- Agents: `khamul` (Product Owner), `witch-king` (final approver / lead engineer), `morgul` (backend), `akhorahil` (frontend), `fellbeast` (review/test).
- Prompts: proposal, plan, implement, release-check, fix-build templates to standardize handoffs.
- Scripts: installer, validators, approval trigger and workflow test helpers.

Agents
- `khamul` — Product Owner (PO): prepares machine-readable proposals with acceptance criteria, prioritizes work, and proposes concrete patches and validation steps. `khamul` does not perform implementation or VCS operations; proposals must be approved by `witch-king` before assignment.
- `witch-king` — Lead Engineer / Final Approver: reviews `khamul` proposals, enforces architecture and safety rules, and escalates breaking or data-loss-risk changes to the human operator for manual sign-off. `witch-king` issues final acceptance before implementation proceeds.
- `morgul` — Backend Implementer: implements APIs, database changes, integrations and server-side logic. Acts only on approved `khamul` proposals and follows the acceptance criteria and test commands provided in the proposal.
- `akhorahil` — Frontend Implementer: implements UI, React/TypeScript, and client-side integration work. Operates only after `witch-king` approval of the PO proposal.
- `fellbeast` — Reviewer & Gatekeeper: writes and runs tests, validates builds, and gates releases. `fellbeast` returns pass/fail verdicts that `witch-king` uses for final acceptance.

Agent restrictions
- No agent in this pack performs `git commit`, `git push`, `git revert` or other repository mutations without explicit, documented user approval. VCS mutations require a clear proposal, `witch-king` approval, and an explicit user confirmation step.

How to use the agents (short)
- Draft a proposal with the `khamul` template, send it to `witch-king` for review, and after approval assign the task to `morgul`/`akhorahil`. Use `fellbeast` to validate the results before final acceptance.

Installing

Windows (PowerShell):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-global-nazgul.ps1 -DryRun
# then when ready:
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-global-nazgul.ps1 -Force -RunChecks
```

macOS / Linux:

```bash
./scripts/install-global-nazgul.sh --dry-run
./scripts/install-global-nazgul.sh --force
```

Installer options
- `-DryRun`: preview changes without writing files.
- `-Force`: overwrite existing files in the user Copilot folders.
- `-RunChecks`: run `scripts/_check_agents.ps1` after install and write a log (default log path: `%USERPROFILE%\.copilot\nazgul\install_log_<timestamp>.txt`).
- `-LogPath <path>`: explicitly set the post-install log file.

Safety & rollback
- The installer is idempotent and will skip files unless `-Force` is provided.
- Recommended rollback procedure:
  1. Run installer with `-DryRun` to verify changes.
  2. If overwriting, create a backup of `%USERPROFILE%\.copilot\agents` and `%USERPROFILE%\.copilot\nazgul` to a timestamped folder.
  3. After install, if you need to revert, run the corresponding uninstall script and restore your backup.

Policy: no VCS mutations without explicit approval
- Agents in this pack are explicitly prohibited from performing `git commit`, `git push`, `git revert` or other repository mutations without a clear, explicit, user-approved action documented in the proposal and confirmed by the user. This is enforced by documentation and by workflow checks — human approval is required for VCS operations.

Proposal & approval flow (brief)
- `khamul` drafts machine-friendly proposals (use `prompts/khamul-proposal.template.md`).
- `witch-king` performs final approval and escalates breaking or data-loss-risking changes to the user for manual review.
- After approval, implementer agents (`morgul`, `akhorahil`) perform implementation work; reviewer (`fellbeast`) runs tests and gates releases.

Contributing
- Please open PRs against this repository. Use `scripts/validate_frontmatter.ps1` locally or CI to validate agent frontmatter and `scripts/test_workflow.ps1` to run workflow dry-runs.

More docs
- See `docs/` and `prompts/` for templates, examples and detailed usage guides.

Questions or issues
- Open an issue or start a discussion in the repo; breaking or destructive change proposals should be flagged for `witch-king` review.

---

Pre-commit (local setup)
- Install and enable pre-commit hooks:

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

Use `pre-commit` to run formatting and static checks before commits.

