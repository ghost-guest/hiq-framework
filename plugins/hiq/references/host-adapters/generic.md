# Generic Adapter

Use this adapter for any host that can run a command but does not yet have a dedicated HiQ integration.

## POSIX

```bash
bash "$HOME/.hiq/scripts/hiq-hook.sh" . pre-session --host=generic --adapter=generic
bash "$HOME/.hiq/scripts/hiq-hook.sh" . pre-tool --host=generic --adapter=generic --tool=<tool-name>
bash "$HOME/.hiq/scripts/hiq-hook.sh" . post-tool --host=generic --adapter=generic --tool=<tool-name>
bash "$HOME/.hiq/scripts/hiq-hook.sh" . pre-final --host=generic --adapter=generic
```

## Windows

```cmd
%USERPROFILE%\.hiq\scripts\hiq-hook.cmd . pre-session --host=generic --adapter=generic
%USERPROFILE%\.hiq\scripts\hiq-hook.cmd . pre-tool --host=generic --adapter=generic --tool=<tool-name>
%USERPROFILE%\.hiq\scripts\hiq-hook.cmd . post-tool --host=generic --adapter=generic --tool=<tool-name>
%USERPROFILE%\.hiq\scripts\hiq-hook.cmd . pre-final --host=generic --adapter=generic
```

This adapter can prove `turn-scoped` once a run file exists. It cannot claim `persistent` unless the host also proves it invokes the commands automatically for each lifecycle event.
