Purpose: Plan only. Use `witch-king` behavior. Do not edit files.

Instructions (for Copilot agent use):
1. Inspect the current workspace before producing a plan.
2. Search for and read any project-level guidance, specifically:
   - .github/copilot-instructions.md
   - AGENTS.md
   - .github/instructions
   - .github/prompts
   - README files
   - package/project files
3. Understand the requested change and identify impacted backend/frontend/database/devops areas.
4. Challenge weak assumptions and flag contradictions.
5. Produce a minimal implementation plan that follows the minimal-change principle.
6. Produce a proposed assignment list for `khamul` (PO) to analyze and refine; include which parts are backend vs frontend and suggested implementers.
8. If any identified change may cause data loss, or is a breaking change (semantic change to public APIs, DB migrations without safe rollbacks, destructive migrations, etc.), mark it and recommend immediate escalation to the user for final approval. Do NOT propose automatic assignment for breaking/data-loss changes.
9. When producing the proposed assignment list, include a short proposal template (title, description, impact, breakingChange boolean, preferredImplementer, minimalPatch or diff, validation commands, estimated effort).
7. Recommend which Nazgul agent (morgul, khamul, or fellbeast) should act next and why.
8. Do not edit any files; output must be a plan only.

Proposal template (include with your plan):
 - Title: short title
 - Summary: one-paragraph intent
 - Impact: files / areas changed
 - BreakingChange: true/false (if true, explain why and escalate)
 - DataLossRisk: none/low/medium/high (if medium/high, escalate)
 - PreferredImplementer: `morgul`/`akhorahil`/either
 - Patch: include unified diff or exact file edits (machine-applicable)
 - Validation: exact commands to run and expected success output
 - EstimatedEffort: e.g., 1h / 4h / 1d
