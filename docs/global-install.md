# Global install

Windows:
  .\scripts\install-global-nazgul.ps1
  .\scripts\install-global-nazgul.ps1 -DryRun
  .\scripts\install-global-nazgul.ps1 -Force

Options:
- `-DryRun`: show what would be copied without making changes.
- `-Force`: overwrite existing files in user Copilot folders.
- `-RunChecks`: after install, run `scripts/_check_agents.ps1` and capture output.
- `-LogPath <path>`: optional path to write post-install check log. If not provided, log is written to `%USERPROFILE%\.copilot\nazgul\install_log_<timestamp>.txt`.

macOS/Linux:
  ./scripts/install-global-nazgul.sh
  ./scripts/install-global-nazgul.sh --dry-run
  ./scripts/install-global-nazgul.sh --force

Uninstall / Rollback
- To uninstall the installed agent files and prompts, run the uninstall script appropriate for your platform:
  - Windows:
    - `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\uninstall-global-nazgul.ps1 -Force`
  - macOS/Linux:
    - `./scripts/uninstall-global-nazgul.sh --force`
- Rollback plan (recommended before running destructive updates):
  1. Run installer with `-DryRun` to verify changes.
  2. If overwriting existing files, create a backup by copying `%USERPROFILE%\.copilot\agents` and `%USERPROFILE%\.copilot\nazgul` to a timestamped folder.
  3. After installing, if something is wrong, run the uninstall script and restore the backup folder.

Notes
- The installer is idempotent by default and will skip files unless `-Force` is supplied.
- Use `-RunChecks` to automatically verify installed agents (opt-in). The check log helps debugging and should be reviewed after install.
