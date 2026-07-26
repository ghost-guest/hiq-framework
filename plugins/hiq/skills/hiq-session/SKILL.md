---
name: hiq-session
description: >-
  HiQ 会话连续性与运行时状态总控。吸收原 session / continue / finish / handoff /
  profile，并内化 Comet 风格的 `status` / `resume-probe` / machine-readable current change：
  负责开场、续作、收口、checkpoint、compact-safe 恢复、状态快照、断点探针与协作约束落盘。
  核心原则：会话续作依赖本地恢复包与 current-change 记录，不依赖聊天历史；一旦上下文变危险，
  先写 checkpoint 再换会话。
---

# hiq-session — 开场 · 续作 · 状态 · Handoff · Compact-safe

## Owns

- Session start and resume reconstruction
- Finish / stop-point preparation
- Handoff checkpoint generation
- Compact-safe session packet under `.hiq/session.md`
- Machine-readable current change mirror under `.hiq/current-change.json`
- Runtime status snapshot and resume probe
- Durable collaboration constraints and operator notes
- Choosing the truthful next skill after the session state is rebuilt

## Modes

- `start` — begin or normalize a working session in a repo that already has baseline files
- `resume` — recover after restart, new chat, or context compaction
- `continue` — same work, but pointer/state may be stale and must be rebuilt
- `finish` — close the current work slice and leave a clean next-step pointer
- `handoff` — prepare checkpoint and exact resume instruction for another session/agent
- `profile` — persist durable collaboration/tool constraints into local memory files
- `status` — emit a compact operational snapshot from local files only
- `resume-probe` — test whether a new session could continue safely from local state right now

## First principle

```text
Chat history is optional.
Local recovery state is mandatory.
If local files and the current-change mirror cannot restart the work,
the session is not safely managed yet.
```

## Trust order

When signals disagree, trust in this order:

1. `.hiq/BOOTSTRAP.md`
2. `.hiq/MEMORY.md`
3. `.hiq/config.yaml`
4. `.hiq/session.md`
5. `.hiq/current-change.json`
6. active `.hiq/changes/<id>/...`
7. latest `context-checkpoints/<...>.md` referenced by session
8. `.hiq/MAP.md` + `.hiq/graph/*` + current CodeGraph health
9. chat history last

## Trigger signals

Use `hiq-session` when any of these are true:

- The user says start, resume, continue, handoff, finish, profile, status, or probe
- A new chat must recover project state from local files
- Context pressure is rising and a checkpoint should be written before continuing
- The next truthful owner skill is unclear because the pointer is stale
- Durable collaboration/tool constraints should be written into local project memory
- The user wants a dashboard-style status summary without reopening product planning

## Spec

```text
STATE detect:
  infer mode from the user request and current session state
  if no `.hiq/` baseline exists:
    route to hiq-init and stop

STATE read_local_truth:
  MUST read:
    `.hiq/BOOTSTRAP.md`
    `.hiq/MEMORY.md`
    `.hiq/config.yaml`
    `.hiq/session.md`
    `.hiq/current-change.json`
  SHOULD read:
    active change files named by session/current-change
    latest checkpoint named by session
    `.hiq/MAP.md`
    `.hiq/graph/*`
    current codegraph status or known health
  if local truth and chat disagree:
    local truth wins

STATE classify_mode:
  start:
    baseline exists, but a fresh working pointer is needed
  resume:
    new session/new chat/restart after loss of live context
  continue:
    same thread but pointer may be stale or incomplete
  finish:
    work slice is ending; leave a clean next pointer
  handoff:
    another session/agent must continue safely
  profile:
    write durable constraints to MEMORY/attention/session, not to chat only
  status:
    emit current truth compactly without changing the task owner
  resume-probe:
    judge whether a brand new session could continue from local files alone

STATE rebuild_pointer:
  reconstruct or refresh these fields in `.hiq/session.md`:
    active_change
    phase
    next_skill
    next_step
    goal_now
    blockers
    acceptance_target
    verify_commands
    codegraph_state
    codegraph_anchors
    last_green
    latest_checkpoint
    compact_safe_summary
    last_action
    next_action
  mirror the operational subset into `.hiq/current-change.json`:
    activeChange
    phase
    ownerSkill
    nextSkill
    nextStep
    goalNow
    acceptanceTarget
    latestCheckpoint
    updatedAt
  if a field is missing, derive it from active change docs before asking the user

STATE session_packet:
  ensure `.hiq/session.md` stays the compact-safe resume packet
  keep it concise and operational, not a log dump
  store only what a new session truly needs next
  ensure `current-change.json` stays machine-readable and aligned with the packet

STATE status_emit:
  when mode=status:
    emit a short snapshot from local state:
      active change and phase
      current goal
      blockers
      next skill
      checkpoint status
      codegraph health
    prefer `hiq-status`-style output shape over prose sprawl

STATE resume_probe:
  when mode=resume-probe:
    test whether these are all true:
      BOOTSTRAP/MEMORY/config/session/current-change exist
      active change path exists when referenced
      checkpoint path exists when referenced
      next owner skill is explicit
    if any item fails:
      mark the probe partial/failing and name the missing local state

STATE checkpoint_gate:
  if mode is handoff OR context pressure is high OR logs/debug work made the thread unsafe:
    write `context-checkpoints/<short-name>-<YYYYMMDD-HHmm>.md`
    required sections:
      Task
      Current Status
      Confirmed Facts
      Key Evidence
      Decisions
      Open Questions
      Next Steps
      Resume Instruction
    update both `.hiq/session.md` and `.hiq/current-change.json`
    emit the exact continue instruction

STATE finish_contract:
  when mode=finish:
    set phase to idle or the next truthful phase
    update last_action and next_action
    record blockers, latest known green checks, and current acceptance target
    if lessons or stable constraints were learned:
      route/update MEMORY or hiq-knowledge as appropriate

STATE profile_contract:
  when mode=profile:
    write durable tool/process/collaboration constraints into:
      `.hiq/MEMORY.md`
      `.hiq/attention.md`
      `.hiq/session.md` only if immediately operational
    never bury durable constraints only in chat

STATE route:
  after pointer is rebuilt, choose the next truthful owner skill:
    unclear scope/acceptance/plan -> hiq-grill
    approved IMPLEMENT and coding next -> hiq-implement
    root-cause mystery -> hiq-debug
    proof/release/acceptance verdict -> hiq-review
    evolution lane -> hiq-evolve
    knowledge capture lane -> hiq-knowledge
    framework-governance lane -> hiq-skill
  session itself should not keep product work when another retained skill is the real owner
```

## Required session fields

`.hiq/session.md` must preserve these fields in recoverable form:

- started / updated / agent
- active_change
- phase
- next_skill
- next_step
- goal_now
- blockers
- acceptance_target
- verify_commands
- codegraph_state
- codegraph_anchors
- last_green
- latest_checkpoint
- compact_safe_summary
- last_action
- next_action

`.hiq/current-change.json` must preserve these fields in machine-readable form:

- activeChange
- phase
- ownerSkill
- nextSkill
- nextStep
- goalNow
- acceptanceTarget
- latestCheckpoint
- updatedAt

## I/O

| Input | Role |
|------|------|
| `.hiq/BOOTSTRAP.md` | root recovery contract |
| `.hiq/MEMORY.md` | durable project memory and constraints |
| `.hiq/config.yaml` | runtime/status/eval defaults |
| `.hiq/session.md` | compact-safe session packet |
| `.hiq/current-change.json` | machine-readable change pointer |
| active `.hiq/changes/<id>/...` | current execution truth |
| latest checkpoint | context-safe handoff truth |
| `.hiq/MAP.md` and `.hiq/graph/*` | structural recall |
| Output | updated session packet, current-change mirror, optional checkpoint, optional MEMORY/attention refresh |

Templates:

- `plugins/hiq/references/templates/session.md`
- `plugins/hiq/references/templates/BOOTSTRAP.md`
- `plugins/hiq/references/templates/config.yaml`
- `plugins/hiq/references/templates/current-change.json`

## Checkpoint rules

Write a checkpoint before session switch when any of these are true:

- context pressure is visibly high
- the thread accumulated many logs, tool outputs, or long debugging branches
- another chat or agent will continue the work
- the current change has non-trivial open loops that should not be reconstructed from memory

The checkpoint must be linked from `.hiq/session.md` and mirrored into `.hiq/current-change.json`.
No checkpoint path, no safe handoff.

## Gates

- Never rely on chat history as the sole resume source
- If local files and chat disagree, local files win
- Large logs/debug output go to files or checkpoints, not into `session.md`
- Every high-context handoff must write a checkpoint path into local state
- `hiq-session` does not replace the real owner skill; once the pointer is rebuilt, route onward
- Durable collaboration constraints must be written locally, not left implicit in chat
- Status/probe output must stay compact and operational

## Announce

```text
session: start|resume|continue|finish|handoff|profile|status|resume-probe
active_change: <id>|none
phase: <phase>
checkpoint: <path>|none
next: <skill>
why: <one line>
```

## Anti-patterns

1. "继续昨天的" but no local pointer update
2. New session that depends on chat memory to know the next step
3. Compacting without a checkpoint path in local state
4. Storing giant logs or tool dumps inside `session.md`
5. Letting active change docs drift away from the session pointer
6. Using `hiq-session` as a permanent owner instead of handing off to the real next skill
7. Claiming status is healthy while the current-change mirror is stale or missing

## Done

A brand new session can continue from local files alone, the current stop-point is explicit in both human and machine-readable form, and handoff/compact cannot erase critical development state.
