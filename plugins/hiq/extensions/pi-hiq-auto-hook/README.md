# Pi HiQ Auto Hook

Pi host adapter for HiQ.

Responsibilities:

- On `session_start`, fire `hiq-hook pre-session --host=pi --adapter=pi`
- On the first `before_agent_start` in a HiQ-managed repo, activate `hiq-auto` local state if no active goal exists yet
- On `agent_settled`, fire `hiq-hook pre-final --host=pi --adapter=pi`

This extension only activates in trusted projects that contain both:

- `AGENTS.md` with the HiQ project rule
- `.hiq/config.yaml`

It does not claim `persistent` automation by itself. It proves `turn-scoped` execution through hook evidence under `.hiq/hooks/runs/`.
