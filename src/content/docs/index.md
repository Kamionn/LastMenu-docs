---
title: LastMenu
description: Universal standalone menu system for FiveM — zero dependencies, one API, real-time reactivity.
order: 0
---

## What is LastMenu?

**LastMenu** is a complete UI library for FiveM. It unifies all common menu types (context, radial, input form, alert, notification, progress bar, target) under a **consistent builder API**, without requiring `ox_lib`, `qbx_core` or any other framework.

The Svelte 5 UI is **pre-compiled** into `ui/assets/` — no `npm install` required on the game server.

## Why LastMenu?

| Common problem | Solution |
|---|---|
| Dependency on `ox_lib` or a framework | Zero runtime dependencies |
| Different API per menu type | One builder pattern for everything |
| No reactivity — close/reopen to refresh | Built-in reactive polling engine |
| Locked to a framework (ESX / QBCore) | Works in any environment |
| Watcher bugs crash the whole menu | Safe Mode automatically disables faulty watchers |
| Back button returns to wrong level | Navigation stack preserves full depth |

## Getting Started

Start with [Installation](introduction/installation) to set up LastMenu on your server, then check the [Quick Start](introduction/quickstart) for practical examples.
## Quick Overview

The entire LastMenu API follows the same pattern: one export call + a builder function.

```lua
local UI = exports['LastMenu']

-- Context menu
UI:context(function(menu)
    menu:title("My Menu")
    menu:button("Say hello", {
        icon = "hand",
        cb   = function() print("Hello!") end
    })
end)

-- Notification
UI:notify(function(n)
    n:message("Action successful.")
    n:type("success")
end)

-- Blocking form (inside a Citizen.CreateThread)
local values = UI:input_async(function(b)
    b:title("Purchase")
    b:field("Quantity", { type = "number", min = 1, max = 10 })
end)
```

## Documentation Structure

| Section | Content |
|---|---|
| [Installation](introduction/installation) | fxmanifest, server.cfg, first steps |
| [Quick Start](introduction/quickstart) | Practical examples by use case |
| [Context Menu](composants/context-menu) | Vertical menu — all item types |
| [Radial Menu](composants/radial) | Circular quick-action wheel |
| [Input Form](composants/input) | Multi-field modal forms |
| [Modal / Alert](composants/modal) | Confirmation dialogs |
| [Notifications](composants/notifications) | Non-blocking toasts |
| [Progress Bar](composants/progress) | Progress bar with side-effects |
| [Target System](composants/target) | ox_target / qtarget replacement |
| [Reactivity](avance/reactivite) | diff/patch polling engine |
| [Async API](avance/async-api) | input_async and alert_async (coroutine-style) |
| [Sub-menus & Stack](avance/sous-menus) | Navigation stack and nesting |
| [Theming](personnalisation/theming) | CSS custom properties |
| [Migration](personnalisation/migration) | From ox_lib, RageUI, qb-menu |
| [Debugging](personnalisation/debugging) | Built-in diagnostic tools |
| [Common Pitfalls](personnalisation/pitfalls) | Anti-patterns to avoid |
