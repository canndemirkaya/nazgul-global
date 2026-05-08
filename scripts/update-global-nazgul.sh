#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FORCE=0
DRYRUN=0
BACKUP_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    --dry-run) DRYRUN=1; shift ;;
    --backup-dir) BACKUP_DIR="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

AGENTS_DIR="$HOME/.copilot/agents"
NAZGUL_DIR="$HOME/.copilot/nazgul"
PROMPTS_DEST="$NAZGUL_DIR/prompts"
DOCS_DEST="$NAZGUL_DIR/docs"

mkdir -p "$AGENTS_DIR" "$PROMPTS_DEST" "$DOCS_DEST"
if [[ -z "$BACKUP_DIR" ]]; then BACKUP_DIR="$NAZGUL_DIR/backups/$(date +%Y%m%d-%H%M%S)"; fi
mkdir -p "$BACKUP_DIR"

copy_with_backup() {
  local src="$1" dest="$2"
  if [[ ! -f "$src" ]]; then echo "missing $src"; return; fi
  if [[ -f "$dest" && $FORCE -eq 0 ]]; then
    # compare mtimes
    if [[ "$src" -ot "$dest" ]]; then
      echo "skip $dest (up-to-date)"
      return
    fi
  fi
  if [[ -f "$dest" ]]; then
    mkdir -p "$(dirname "$BACKUP_DIR/$dest")"
    backup="$BACKUP_DIR/$(basename "$dest").$(date +%Y%m%d%H%M%S).bak"
    if [[ $DRYRUN -eq 1 ]]; then echo "DRYRUN: backup $dest -> $backup"; else cp -f "$dest" "$backup"; echo "backup $dest -> $backup"; fi
  fi
  if [[ $DRYRUN -eq 1 ]]; then echo "DRYRUN: copy $src -> $dest"; else cp -f "$src" "$dest"; echo "copied $dest"; fi
}

echo "Updating agents..."
for f in "$ROOT"/agents/*.agent.md; do
  [[ -f "$f" ]] || continue
  dest="$AGENTS_DIR/$(basename "$f")"
  copy_with_backup "$f" "$dest"
done

echo "Updating prompts..."
for f in "$ROOT"/prompts/*; do
  [[ -f "$f" ]] || continue
  dest="$PROMPTS_DEST/$(basename "$f")"
  copy_with_backup "$f" "$dest"
done

echo "Updating docs..."
if [[ -d "$ROOT/docs" ]]; then
  for f in "$ROOT/docs"/*; do
    name="$(basename "$f")"
    dest="$DOCS_DEST/$name"
    if [[ -d "$f" ]]; then
      if [[ $DRYRUN -eq 1 ]]; then echo "DRYRUN: copydir $f -> $dest"; else rm -rf "$dest" && cp -r "$f" "$dest"; echo "copied $dest"; fi
    else
      copy_with_backup "$f" "$dest"
    fi
  done
fi

echo "Update complete. backups in: $BACKUP_DIR"
echo "If you used --dry-run nothing was changed."
