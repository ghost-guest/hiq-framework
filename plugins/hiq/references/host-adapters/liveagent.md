# LiveAgent Adapter

LiveAgent is one possible host adapter, not the center of HiQ hook design. Use the same host-neutral hook core as every other adapter.

Recommended event mapping:

- new task or resume -> `pre-session --host=liveagent --adapter=liveagent`
- before material tool execution -> `pre-tool --host=liveagent --adapter=liveagent --tool=<tool>`
- after material tool execution -> `post-tool --host=liveagent --adapter=liveagent --tool=<tool>`
- before final reply -> `pre-final --host=liveagent --adapter=liveagent`
- context pressure -> `checkpoint --host=liveagent --adapter=liveagent --context-pressure=high`

The adapter may use LiveAgent-specific mechanisms when available, but must still leave `.hiq/hooks/runs/` evidence for `hiq-doctor`.
