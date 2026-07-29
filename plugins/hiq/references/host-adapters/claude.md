# Claude Adapter

Claude integration should use the strongest command or lifecycle mechanism available in the user's Claude environment. The adapter must call the host-neutral HiQ hook core and leave run evidence under `.hiq/hooks/runs/`.

Recommended event mapping:

- session start or resume -> `pre-session --host=claude --adapter=claude`
- before tool/action -> `pre-tool --host=claude --adapter=claude --tool=<tool>`
- after tool/action -> `post-tool --host=claude --adapter=claude --tool=<tool>`
- before final response or handoff -> `pre-final --host=claude --adapter=claude`

Do not set `persistent` unless the Claude environment has a verified automatic lifecycle hook configuration and `hiq-doctor` can see recent hook run evidence.
