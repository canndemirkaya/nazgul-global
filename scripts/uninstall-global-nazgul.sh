#!/usr/bin/env bash
set -euo pipefail

DRYRUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRYRUN=1; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

AGENTS_DIR="$HOME/.copilot/agents"
NAZGUL_DIR="$HOME/.copilot/nazgul"

for f in witch-king.agent.md morgul.agent.md khamul.agent.md akhorahil.agent.md fellbeast.agent.md; do
  target="$AGENTS_DIR/$f"
  if [[ $DRYRUN -eq 1 ]]; then echo "DRYRUN remove $target"; else [[ -f "$target" ]] && rm -f "$target" && echo "Removed $target" || echo "Missing $target"; fi
done

if [[ $DRYRUN -eq 1 ]]; then echo "DRYRUN remove $NAZGUL_DIR"; else [[ -d "$NAZGUL_DIR" ]] && rm -rf "$NAZGUL_DIR" && echo "Removed $NAZGUL_DIR" || echo "Missing $NAZGUL_DIR"; fi

echo "Uninstall complete."
