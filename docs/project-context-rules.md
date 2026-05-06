# Project context rules

Global agents must inspect project-level guidance and prefer project conventions when present.

Inspect in order:
- .github/copilot-instructions.md
- AGENTS.md
- .github/instructions
- .github/prompts
- README files
- package/project files

Conflict resolution:
- Security and validation rules take priority.
- Existing project conventions take priority over generic stylistic preferences.
- Explicit user requests take priority only if they don't weaken security, validation, or correctness.
