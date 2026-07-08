# Codebase map (onboarding 2026-07-08)

**Windows Provisioning Toolkit** — PowerShell automation to provision a fresh
Windows machine: Windows Updates, Winget app installs, software inventory
export, and a startup scheduled task for auto-updates.

## Layout
- `WindowsProvisioning.ps1` — the toolkit (main script; all functions).
- `setup.json` — declarative config: the app list (Winget IDs) + options.
- `Installed_Programs.txt` — exported software inventory (output artifact).
- `Provisioning_Log.txt` — run log (output artifact).
- `README.md` / `README.de.md` — usage (keep in sync, both languages).

## Run
PowerShell (elevated). Reads `setup.json`, installs Winget apps, applies
updates, exports inventory, optionally registers a startup scheduled task.

## Conventions
- Windows PowerShell 5.1 target; use `-Confirm:$false` for unattended runs.
- No secrets in the repo; config is non-sensitive (Winget IDs).
- Keep both READMEs in sync.

## Notes
No build/test framework — validation is running the script on a Windows host.
Idempotency matters (re-runnable provisioning).
