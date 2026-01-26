# 方案 03：仓库拆分 / 模块化治理（ADR 风格）

目标：把 Flutter（移动端）与 Python/Gradio（web 工具）从“同仓混杂”变成“边界清晰、可独立构建发布”的工程形态。

- 上层综述：`docs/code-review.md`
- 原方案草案：`docs/方案-拆分仓库与模块化治理.md`

## 文档结构

- `README.md`
- `adr/`
  - `0201-decide-product-boundary-web-is-backend-or-independent.md`
  - `0202-repo-split-vs-monorepo-packages.md`
  - `0203-history-migration-strategy.md`
  - `0204-ci-cd-split-and-ownership.md`
  - `0205-runtime-reproducibility-docker-and-lockfiles.md`

## 快速决策导航

先决定 `web/` 与 Flutter 的关系（ADR 0201），再决定拆分形态（ADR 0202）。
