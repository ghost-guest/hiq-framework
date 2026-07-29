# HiQ Hooks

Host-neutral hook evidence lives here.

- protocol: .hiq/hooks/hook-state.json + .hiq/hooks/runs/
- adapters: .hiq/hooks/adapters/
- core command: bash "$HOME/.hiq/scripts/hiq-hook.sh" . pre-session --host=generic --adapter=generic
- Windows: %USERPROFILE%\.hiq\scripts\hiq-hook.cmd . pre-session --host=generic --adapter=generic

Do not claim host-level automation from this directory alone. Run evidence under .hiq/hooks/runs/ is required.
