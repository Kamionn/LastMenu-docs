---
title: LastMenu
description: FiveM 通用菜单系统 — 零依赖，一个 API，实时响应。
order: 0
---

## 什么是 LastMenu？

**LastMenu** 是 FiveM 的完整 UI 库。它将所有常见菜单类型（上下文、径向、输入表单、警报、通知、进度条、目标）统一在**一致的构建器 API** 下，无需 `ox_lib`、`qbx_core` 或任何其他框架。

Svelte 5 UI 在 `ui/assets/` 中**预编译** — 游戏服务器端不需要 `npm install`。

## 为什么选择 LastMenu？

| 常见问题 | 解决方案 |
|---|---|
| 依赖 `ox_lib` 或框架 | 运行时零依赖 |
| 每个菜单类型不同的 API | 一个构建器模式适用于所有 |
| 无响应性 — 关闭/打开以刷新 | 集成的响应式轮询引擎 |
| 锁定到框架 (ESX / QBCore) | 在任何环境中工作 |