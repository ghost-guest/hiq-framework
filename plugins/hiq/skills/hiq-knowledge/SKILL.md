---
name: hiq-knowledge
description: >-
  HiQ 项目长期记忆总控。吸收原 adr / keep / audit：架构决策、可复用 lessons、
  失败后多轮修复才成功的 casebook、主动审计都走这里。核心不是“记笔记”，而是把以后
  还会救命、省时间、防再踩坑的知识沉淀成 durable artifact，并把它链接回 `.hiq/` 的
  真实来源与未来消费者。
---

# hiq-knowledge — ADR · Lessons · Casebook · Audit

## Owns

- ADR and irreversible decision capture
- Reusable lessons and default rules
- Casebook timelines for multi-attempt failures or recoveries
- Proactive audits and their follow-up obligations
- Linking source work into durable knowledge artifacts
- Updating the memory/spec surfaces future sessions should actually read

## Modes

- `adr` — architecture or policy decision with long-term consequences
- `lesson` — reusable implementation, debugging, review, or ops rule
- `casebook` — a path-to-fix record where failed attempts matter as much as the final answer
- `audit` — proactive inspection that should change future behavior or priorities
- `handoff` — pause or switch sessions while preserving what knowledge still needs to be written

## First principle

```text
The final fix alone is not enough knowledge.
If future work would pay the rediscovery cost again,
write the rule, timeline, or decision in the right artifact class.
```

## Trigger signals

Use `hiq-knowledge` when one or more are true:

- A decision changes architecture, workflow, policy, or compatibility assumptions
- A bug or delivery issue required multiple meaningful attempts before success
- A review/debug/evolve cycle revealed a reusable rule, trap, or verification habit
- An audit produced findings that should shape future implementation or review behavior
- A future session would be slower or riskier if this insight stayed only in chat

Do not use `hiq-knowledge` for transient status or generic recap.
Do not stay here when the real work is still planning, implementation, debugging, or review.

## Spec

```text
STATE trigger_check:
  inspect current change/debug/review/evolve/session context
  ask:
    would this save future work?
    would losing this force the same rediscovery again?
    is there a durable artifact class that fits?
  if the answer is no:
    do not write knowledge

STATE classify:
  adr if the artifact is a durable decision with alternatives and consequences
  lesson if the artifact is a reusable rule or checklist
  casebook if the value is in failed attempts, wrong hypotheses, or misleading signals before recovery
  audit if proactive inspection produced findings, priorities, and actions
  handoff if capture started but another session must finish it

STATE source_collect:
  gather durable inputs only:
    change-id / issue / incident / audit scope
    IMPLEMENT.md / debug.md / review.md / evolve.md / evidence.md
    decisive commands, observations, screenshots, logs (summary only)
  reject vague memory with no traceable source work

STATE distill:
  extract the minimum future-useful truth:
    scenario and pressure
    initial assumption or prior state
    decisive evidence
    real root cause or decision logic
    final rule / decision / repair path
    verification or regression hook
    when this does NOT apply
  pick the narrowest artifact class that still preserves the lesson

STATE artifact_write:
  adr:
    record context, decision, alternatives, consequences, and follow-on obligations
  lesson:
    record default rule, apply/not-apply signals, evidence, next-time checklist
  casebook:
    record attempt-by-attempt timeline, why each attempt failed, decisive evidence, final repair, future default rule
  audit:
    record scope, findings, priorities, actions, and next owner

STATE connect:
  link the artifact back to source work and forward to future consumers:
    change folder
    issue / incident
    related ADR / lesson / casebook / audit
    BOOTSTRAP / MEMORY / CONTEXT / spec when future defaults changed
  if the knowledge should alter how HiQ works next time:
    update the relevant `.hiq/` surface, not just the knowledge file

STATE quality_gate:
  ADR must include alternatives and consequences
  Lesson must include when to apply and when not to apply
  Casebook must preserve each meaningful failed attempt and why it failed
  Audit must include action priority and follow-up owner
  no artifact may be chat fluff, vanity summary, or unsupported claim

STATE handoff:
  if context/session must switch mid-capture:
    record which artifact class is needed, source work gathered, missing sections, and future consumer
```

## I/O

| Artifact | Path | Role |
|----------|------|------|
| ADR | `.hiq/adr/` | architecture, policy, or irreversible decision record |
| Lesson | `.hiq/knowledge/lessons/` | reusable rule, checklist, or trap-to-avoid |
| Casebook | `.hiq/knowledge/casebook/` | multi-attempt failure or recovery timeline |
| Audit | `.hiq/audits/` | proactive scope, findings, priority, and actions |
| Source links | `.hiq/changes/<id>/...` | traceable origin for the knowledge |
| Memory/spec surfaces | `.hiq/BOOTSTRAP.md`, `.hiq/MEMORY.md`, `.hiq/CONTEXT.md`, `.hiq/spec/...` | future-reader entry points |
| Output | durable artifact with linked source work and future-use rule |

Templates:

- `plugins/hiq/references/templates/lesson.md`
- `plugins/hiq/references/templates/casebook.md`

## Required knowledge truths

The chosen artifact must preserve these in recoverable form:

- why this was worth remembering
- exact source work or evidence behind it
- the future rule, decision, or warning
- when the rule applies and when it does not
- what future verification or regression hook proves it still matters
- which `.hiq/` surfaces should point future sessions toward it

## Knowledge rules

1. Write the narrowest durable artifact that still prevents rediscovery
2. A lesson with no evidence is opinion, not knowledge
3. A casebook that skips failed attempts loses half its value
4. If the insight changes future defaults, update the future-entry surface too
5. Prefer concrete rules and links over broad retrospective prose
6. If the insight is still changing because the work is not done, wait or hand off honestly

## Announce

```text
knowledge: <slug-or-path>
mode: adr|lesson|casebook|audit|handoff
source: <change/debug/review/evolve/audit>
future_rule: <one line>
linked_to: <files/change-id/issue>
next: hiq-knowledge | hiq-session | hiq-grill | hiq-implement | hiq-debug | hiq-review
```

## Gates

- Do not store transient conversation recap as durable knowledge
- Do not write a lesson that is really just a one-off status note
- Do not collapse a multi-attempt recovery into only the final successful patch
- Do not record conclusions unsupported by files, commands, or observed behavior
- Do not leave future-entry surfaces stale when the new rule should change how work starts
- Do not keep pending knowledge capture only in chat when a handoff is needed

## Anti-patterns

1. Recording only the final patch and losing the failed-attempt history
2. Writing “经验” with no evidence or future reuse value
3. ADR with decision but no alternatives or consequences
4. Casebook that says “试了很多次” but does not name each hypothesis and failure reason
5. Audit that lists problems but no priority, owner, or next action
6. Discovering a durable rule and never updating BOOTSTRAP, MEMORY, CONTEXT, or spec references

## Done

Durable project knowledge is written in the right artifact class, linked to real source work, connected to the future-reader surfaces that need it, and strong enough to prevent the same rediscovery cost next time.