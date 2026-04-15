---
title: Debugging
description: Enable debug mode, use console commands, diagnose watcher errors and NUI communication issues.
order: 3
lastUpdated: 2026-04-14
---

## Enable Debug Mode

In `client/config.lua`:

```lua
Config.debug = true
```

In debug mode, LastMenu displays in the resource console:
- Evaluation / patch counters / watcher errors, every 60 ticks per active menu
- Recovery attempts after Safe Mode
- Type validation warnings from builders (wrong types passed to `field.min`, etc.)

To debug specifically the **target system** (draws zone outlines in-game):

```lua
Config.debugTarget = true
```

---

## Console Commands

### `/lm_debug`

Displays a snapshot of the state of all active watchers in the **server console**:

```
[LastMenu] ── Watcher stats ──────────────────────────
  Menu: 1735000000_1
    cb=cb_1735000000_1_shop_item_1   field=disabled  interval=500ms  errors=0  status=ok
    cb=cb_1735000000_1_shop_item_2   field=visible   interval=500ms  errors=2  status=ok
    cb=cb_1735000000_1_shop_item_3   field=disabled  interval=500ms  errors=3  status=retry@1735015000
[LastMenu] ─────────────────────────────────────────
```

**Status values:**

| Status | Meaning |
|---|---|
| `ok` | Active and healthy watcher |
| `DISABLED` | Safe Mode active — indicates a bug in `reactive.lua` if no retryAt |
| `retry@<timestamp>` | Safe Mode active — recovery attempted when `GetGameTimer()` reaches this value |

### Via export (from another resource)

```lua
exports.LastMenu:debug_stats()
```

---

## Reading Watcher Errors

When a watcher function throws an error 3 times in a row:

```
[LastMenu] Watcher DISABLED [1735000000_1:disabled] — will retry in 15s.
Error: attempt to index a nil value (global 'playerData')
```

The error message is the Lua error thrown by the watcher function.

| Error Message | Probable Cause |
|---|---|
| `attempt to index a nil value` | Access to a not yet initialized variable |
| `attempt to perform arithmetic on a nil value` | Number used before being defined |
| `stack overflow` | Infinite recursion in the watcher |
| `bad argument #1 to 'X'` | Wrong type passed to a native or function |

---

## Diagnosing NUI Communication

If a menu opens but the buttons don't respond:

**1. Open Chromium DevTools NUI**: in FiveM, enter `nui_devtools` in the F8 console (development builds only).

**2. Console tab** — search for JavaScript errors.

**3. Network tab** — NUI messages appear as `fetch` calls to `https://lastmenu/`.

**4. Verify** that `Bridge.onCallback` registers the correct `cb_id` — check the Lua console for `[LastMenu] ...` messages during the opening sequence.

---

## Common Symptoms

### The menu opens but closes immediately

- Verify that `Stack.pop()` is not called twice (e.g., `onComplete` and the default completion handler are both registered — use only one).
- Verify that another resource is not calling `lastmenu_back` unexpectedly.

### NUI focus remains blocked after restarting a resource

The resource stopped while a menu was open and `onResourceStop` didn't have time to execute. Solutions:

1. Run `SetNuiFocus(false, false)` from the F8 console.
2. Restart the LastMenu resource.
3. Call `exports.LastMenu:lastmenu_back()` from another resource.

### Watchers stop updating after a few seconds

Safe Mode triggered. Run `/lm_debug` to see which watcher is disabled and what error it threw. Fix the watcher function — the menu will recover automatically in 15s.

### `UI:alert_async` / `UI:input_async` returns `false` immediately

Called outside a coroutine. Wrap the call in a `Citizen.CreateThread`. See [Common Pitfalls](/docs/personnalisation/pitfalls#3-calling-async-outside-a-coroutine).

---

## Inspecting the Stack

```lua
-- From a callback or a watcher:
-- LastMenu.Stack.peek() returns { id, type, level, nav } or nil
-- The type values are: 'context', 'alert', 'input', 'progress', 'radial', 'target'
```

The stack is on the NUI side (`$state` in `App.svelte`). Lua maintains a mirror counter for cursor and focus management.
