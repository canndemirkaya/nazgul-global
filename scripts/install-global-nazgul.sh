#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FORCE=0
DRYRUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    --dry-run) DRYRUN=1; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

AGENTS_DIR="$HOME/.copilot/agents"
NAZGUL_DIR="$HOME/.copilot/nazgul"

if [[ ! -d "$ROOT/agents" ]]; then echo "Missing agents/ directory in installer root." >&2; exit 1; fi
if [[ ! -d "$ROOT/prompts" ]]; then echo "Missing prompts/ directory in installer root." >&2; exit 1; fi

mkdir -p "$AGENTS_DIR"
mkdir -p "$NAZGUL_DIR/prompts"

copy_file() {
  local src="$1" dest="$2"
  if [[ $DRYRUN -eq 1 ]]; then echo "DRYRUN: copy $src -> $dest"; return; fi
  if [[ -f "$dest" && $FORCE -eq 0 ]]; then echo "skip $dest"; return; fi
  cp -f "$src" "$dest"
  echo "copied $dest"
}

for f in "$ROOT"/agents/*.agent.md; do copy_file "$f" "$AGENTS_DIR/$(basename "$f")"; done
for f in "$ROOT"/prompts/*.prompt.md; do copy_file "$f" "$NAZGUL_DIR/prompts/$(basename "$f")"; done

if [[ $DRYRUN -eq 0 ]]; then
  cp -r "$ROOT/docs" "$NAZGUL_DIR/docs" || true
  cp "$ROOT/README.md" "$NAZGUL_DIR/README.md" || true
fi

echo "Install complete. Agents: $AGENTS_DIR, Docs: $NAZGUL_DIR"
