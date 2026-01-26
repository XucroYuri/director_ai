# 方案 01：P0 基线（ADR 风格）

目标：以最小变更修复阻断构建/运行、导致数据错误或泄密的 P0 问题，建立稳定的可运行基线。

- 上层综述：`docs/code-review.md`
- 原方案草案：`docs/方案-P0修复与可运行基线.md`

## 文档结构（Vibe Coding / Claude Skills 友好）

- `README.md`
- `adr/`
  - `0001-fix-duplicate-apiconfig-createdio.md`
  - `0002-normalize-conversation-metadata-for-media-cache.md`
  - `0003-stop-logging-api-keys.md`
  - `0004-web-runtime-constraints-for-proxy-and-gradio-deps.md`

## 快速决策导航

- 如果你只想先让 Flutter 编译通过：看 `adr/0001-...`。
- 如果你在意历史会话/缓存可用性：看 `adr/0002-...`。
- 如果你在意安全审计：看 `adr/0003-...`。
- 如果你在意 web 的可运行/可复现：看 `adr/0004-...`。
