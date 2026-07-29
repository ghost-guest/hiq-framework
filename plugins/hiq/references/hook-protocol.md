# HiQ Hook Protocol

HiQ hooks are host-neutral. The core contract is a local command protocol that any agent host can call through its own lifecycle hooks, command wrappers, launch scripts, MCP tools, or session bootstrap mechanism.

## Core Commands

POSIX:

```bash
bash "$HOME/.hiq/scripts/hiq-hook.sh" <project-root> <event> --host=<host> --adapter=<adapter>
```

Windows:

```cmd
%USERPROFILE%\.hiq\scripts\hiq-hook.cmd <project-root> <event> --host=<host> --adapter=<adapter>
```

Repository development:

```bash
bash plugins/hiq/scripts/hiq-run.sh hook . pre-session --host=generic --adapter=generic
```

## Events

- `pre-session`: called when a host opens or resumes work in a project.
- `pre-tool`: called before a host/tool performs a material action.
- `post-tool`: called after a host/tool performs a material action.
- `pre-final`: called before a final response or handoff.
- `checkpoint`: called when context pressure, handoff, or compaction requires a durable resume packet.
- `status`: records no state mutation and returns a hook-compatible status envelope.

## Inputs

Adapters SHOULD pass these fields when the host can provide them:

- `--host=<name>`: host runtime, such as `claude`, `codex`, `pi`, `liveagent`, `project`, `custom`, or `generic`.
- `--adapter=<name>`: adapter name. Use `generic` unless the adapter has host-specific behavior.
- `--tool=<name>`: tool or command being executed, for `pre-tool` and `post-tool`.
- `--context-pressure=<unknown|normal|high|critical>`: context pressure signal when available.
- `--json`: emit the run JSON instead of line output.

## Output

Every run writes a JSON evidence file under `.hiq/hooks/runs/`:

```json
{
  "framework": "hiq",
  "schema": 1,
  "event": "pre-session",
  "host": "generic",
  "adapter": "generic",
  "tool": "",
  "contextPressure": "unknown",
  "cwd": "/project",
  "allow": true,
  "requiredActions": [],
  "ownerSkill": "hiq-auto",
  "status": "pass",
  "createdAt": "<timestamp>"
}
```

The hook updates `.hiq/current-change.json` and `.hiq/session.md` with:

- `hostAutomationLevel=turn-scoped`
- `hostAutomationEvidence=.hiq/hooks/runs/<run>.json`
- `hookProtocolVersion=1`
- `hookCoreStatus=available`
- `hookAdapter=<adapter>`
- `hookLastEvent=<event>`
- `hookLastRunPath=.hiq/hooks/runs/<run>.json`
- `hookLastRunStatus=pass`

## Automation Levels

- `instruction-only`: the project contains HiQ instructions, but no hook evidence exists.
- `adapter-available`: a host adapter exists or is configured, but no current run evidence proves it fired.
- `turn-scoped`: a hook run fired in the current project and left evidence in `.hiq/hooks/runs/`.
- `persistent`: a host provides persistent lifecycle enforcement and the adapter can prove both configuration and recent execution.

HiQ doctor treats run evidence as the source of truth. File presence alone must not upgrade a project to `turn-scoped` or `persistent`.

## Adapter Rule

Adapters only connect host events to `hiq-hook`. They must not rewrite HiQ state directly unless they also write a hook run evidence file that `hiq-doctor` can verify.
