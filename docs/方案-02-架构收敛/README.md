# 方案 02：架构收敛（ADR 风格）

目标：减少重复、降低耦合、提升可测试性与可观测性，让项目进入“可持续迭代”的工程状态。

- 上层综述：`docs/code-review.md`
- 原方案草案：`docs/方案-架构收敛与可维护性提升.md`

## 文档结构

- `README.md`
- `adr/`
  - `0101-dio-factory-and-shared-interceptors.md`
  - `0102-domain-errors-instead-of-string-exceptions.md`
  - `0103-logging-policy-and-runtime-log-level.md`
  - `0104-extract-agent-command-parser-and-add-tests.md`
  - `0105-conversation-metadata-schema-and-compat.md`

## 关键 trade-offs

- 重构幅度 vs 风险：按里程碑拆分，每一步都保持可运行。
- “更像后端的移动端”问题：如果长期要做稳定服务，最终可能需要引入自家后端（与方案 03 决策耦合）。
