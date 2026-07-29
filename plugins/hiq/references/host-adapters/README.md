# Host Adapters

HiQ adapters are thin host-specific connection notes around the host-neutral `hiq-hook` core. No adapter is the default or center of the design.

Use the strongest hook primitive the host offers:

1. Native lifecycle hooks when available.
2. Command/tool wrappers when lifecycle hooks are unavailable.
3. Session bootstrap commands when the host can only run startup instructions.
4. Manual command invocation as a fallback, which remains `instruction-only` until a hook run evidence file exists.

Every adapter should ultimately call one of:

```bash
bash "$HOME/.hiq/scripts/hiq-hook.sh" <project-root> pre-session --host=<host> --adapter=<adapter>
```

```cmd
%USERPROFILE%\.hiq\scripts\hiq-hook.cmd <project-root> pre-session --host=<host> --adapter=<adapter>
```

`hiq-doctor` decides whether the result is `instruction-only`, `adapter-available`, `turn-scoped`, or `persistent` based on real evidence.
