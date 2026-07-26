# Modules

| Module | Path | Responsibility | Key symbols |
|--------|------|----------------|-------------|
| auto-wrapper | `plugins/hiq/skills/hiq-auto` | goal 外层编排、自动选择当前 owner | `hiq-auto` |
| root-router | `plugins/hiq/skills/hiq` | 定级、分流、选择唯一当前主 skill | `hiq` |
| project-init | `plugins/hiq/skills/hiq-init` | `.hiq/` 基线、CodeGraph、eval scaffold | `hiq-init` |
| host-install | `plugins/hiq/skills/hiq-install` | 宿主安装、runtime sync、doctor | `hiq-install` |
| session | `plugins/hiq/skills/hiq-session` | 开场、续作、status、handoff、checkpoint | `hiq-session` |
| planning | `plugins/hiq/skills/hiq-grill` | 立项、研究、架构、计划契约 | `hiq-grill` |
| execution | `plugins/hiq/skills/hiq-implement` | 按批准契约施工、slice 执行 | `hiq-implement` |
| debugging | `plugins/hiq/skills/hiq-debug` | 根因定位、修复闭环、回归保护 | `hiq-debug` |
| review | `plugins/hiq/skills/hiq-review` | 证据、验收、eval、放行 | `hiq-review` |
| evolution | `plugins/hiq/skills/hiq-evolve` | 重构、迁移、性能、加固、退役 | `hiq-evolve` |
| knowledge | `plugins/hiq/skills/hiq-knowledge` | ADR、lesson、casebook、audit | `hiq-knowledge` |
| governance | `plugins/hiq/skills/hiq-skill` | skill 治理、吸收、bundle、publish、sync | `hiq-skill` |
| scripts | `plugins/hiq/scripts` | install/status/doctor/codegraph helpers | `*.sh`, `*.cmd` |
