# HiQ Skill Schema (quality bar)

Every `plugins/hiq/skills/<name>/SKILL.md` MUST meet this bar. Thin name-only stubs are not shippable.

## Required sections

| Section | Purpose |
|---------|---------|
| YAML frontmatter `name` + `description` | Triggers: when to load; what problem; what not |
| `# Title` | Human name |
| `## Spec` | State machine or numbered procedure agents execute |
| `## I/O` | Inputs read + artifacts written (paths under `.hiq/`) |
| `## Gates` | Stop/block conditions; human confirm edges |
| `## Done` | Observable completion criteria |
| `## Anti-patterns` | What not to do (at least 2 concrete) |

Optional: `## Announce`, `## Handoff`, `## Templates` (link `references/templates/`).

## Spec rules

1. **Executable**: agent can follow without inventing ceremony.
2. **Tier-aware**: L0 path shorter than L2/L3; never force ADR on L0.
3. **Sole framework**: all durable state under `.hiq/` (or `.codegraph/` for index).
4. **CodeGraph**: L1+ code work prefers `codegraph_*` / CLI before blind Grep when index healthy.
5. **Evidence**: any "done/fixed/passing" must land in `evidence.md` and clear `hiq-review` before release claims.
6. **Thin skill, deep refs**: keep SKILL.md under ~200 lines; put long tables/examples in `references/`.

## Description quality

- Starts with problem → fix (or clear verb phrase).
- Lists **triggers** (user phrases + situations).
- Says when **not** to use (point to sibling skill).

## Catalog sync

New/renamed skill → update `SKILL_CATALOG.md` + `references/routing-table.md` same change.

## Depth levels (roadmap)

| Level | Meaning |
|-------|---------|
| S0 stub | Name + 1-paragraph Spec only — **not production** |
| S1 thin | Spec + I/O + Gates + Done + Anti-patterns (~30–60 lines) |
| S2 solid | S1 + tier branches + handoffs + failure modes (~80–150) |
| S3 deep | S2 + worked examples / checklists / templates (~150–250) |

Target for lifecycle spine (`session`, `feature`, `issue`, `verify`, `check`, `debug`, `migrate`, `perf`): **S2+**.
