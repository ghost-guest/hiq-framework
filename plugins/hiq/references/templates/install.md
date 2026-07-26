# INSTALL — <target>

> Single source for host/framework installation truth. Use this when `hiq-install` previews, applies, repairs, syncs, or verifies runtime copies for a target host.

- **change**: `.hiq/changes/<id>/`
- **status**: draft | in-progress | done | blocked | partial
- **mode**: preview | apply | repair | sync | verify | doctor
- **target**: liveagent | codex | claude | project
- **approved_to_apply**: no | yes
- **project_dir**: <required when target=project>
- **source_root**: `plugins/hiq/`
- **dest**: `~/.liveagent/skills/...` | `~/.codex/skills/...` | `~/.claude/skills/...` | `<project>/.agents/skills/...`
- **hiq_runtime_home**: `~/.hiq`

## 1. Goal

- what should become true on the host:

## 2. Environment truth

- current machine / agent:
- write access allowed?: yes | no | unknown
- target exists already?: yes | no | partial
- current blocker if any:

## 3. Planned surfaces

- skills source:
- references source:
- scripts source:
- vendor source:
- bundled codegraph pin/source:
- destination surfaces expected after install:

## 4. Backup / rollback

- backup required?: yes | no
- planned backup path:
- rollback path if apply fails:

## 5. Action plan

- preview/apply/repair steps:
- exact installer command or equivalent path:
- what will be skipped if environment blocks writes:

## 6. Health checks

```bash
# destination / count
```

```bash
# runtime / codegraph
```

## 7. Results

- host skill copy status:
- references/scripts/vendor status:
- codegraph runtime status:
- blocked / partial proof:

## 8. Evidence files

- `evidence.md`: preview/apply/verify summaries
- related logs or notes:

## 9. Next owner

- `hiq-install` | `hiq-init` | `hiq-session` | `hiq-skill` | `hiq-debug`
- next action:
