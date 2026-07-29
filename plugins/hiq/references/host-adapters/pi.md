# Pi Adapter

Pi or similar agents may not expose native lifecycle hooks. Use the generic command protocol through whatever launch, bootstrap, wrapper, or tool-call mechanism Pi provides.

Minimum viable mapping:

- session bootstrap -> `pre-session --host=pi --adapter=pi`
- manual or wrapped action boundaries -> `pre-tool` and `post-tool`
- final answer checkpoint -> `pre-final`

If Pi only supports manual invocation, HiQ should report `instruction-only` before the command runs and `turn-scoped` after a run evidence file exists. Do not report `persistent` without a durable host-side configuration and recent evidence.
