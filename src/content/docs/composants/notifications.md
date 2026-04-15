---
title: Notifications
description: Non-blocking stackable toasts — success, error, warning, info. Deduplication by group, persistence and close callbacks.
order: 5
lastUpdated: 2026-04-14
---

## Basic usage

```lua
exports.LastMenu:notify(function(n)
    n:message("Action successful!")
    n:type("success")
    n:duration(3000)
end)
```

### Shortcut pattern

Wrap notifications in a helper function to reduce boilerplate:

```lua
local UI = exports['LastMenu']

local function notify(msg, t, dur)
    UI:notify(function(n)
        n:message(msg)
        n:type(t or 'success')
        n:duration(dur or 2500)
    end)
end

-- Usage
notify("Vehicle repaired!")
notify("Insufficient funds",        "error")
notify("Warning: dangerous area", "warning", 5000)
notify("3 players nearby",     "info",    4000)
```

---

## Builder methods

| Method | Type | Default | Description |
|---|---|---|---|
| `n:message(str)` | `string` | `""` | Toast text |
| `n:type(str)` | `string` | `"info"` | Visual style: `"success"` `"error"` `"warning"` `"info"` |
| `n:duration(ms)` | `number` | `3000` | Auto-close delay |
| `n:icon(str)` | `string` | *(type icon)* | Custom Lucide icon — replaces type icon |
| `n:group(key)` | `string` | `nil` | Deduplication key — **replaces** existing toast with same key |
| `n:persistent()` | — | — | Toast never auto-closes — × button required |
| `n:on_dismiss(cb)` | `function` | `nil` | Called when user clicks × (not on auto-expiration) |

---

## Group deduplication

`n:group(key)` ensures only one toast per semantic topic is visible at a time. When a new toast with the same key arrives, the previous one is immediately replaced:

```lua
-- Only the latest zone toast is visible
UI:notify(function(n)
    n:message("You are entering the Red Zone")
    n:type("warning")
    n:group("zone_status")
end)

-- A few seconds later...
UI:notify(function(n)
    n:message("You are leaving the Red Zone")
    n:type("info")
    n:group("zone_status")  -- replaces the previous one
end)
```

---

## Custom icon

```lua
UI:notify(function(n)
    n:message("New mission available")
    n:type("info")
    n:icon("map-pin")   -- any Lucide icon name
end)
```

---

## Persistent toast

Useful for critical status messages that the player must acknowledge:

```lua
UI:notify(function(n)
    n:message("Server maintenance — reconnection in 60s")
    n:type("warning")
    n:persistent()
    n:on_dismiss(function()
        print("Player acknowledged the message")
    end)
end)
```

---

## Position

Position is configured in **User Settings** (F12):

| Axis | Options |
|---|---|
| X | `left` / `right` |
| Y | `top` / `bottom` |

Default: `bottom-right`.

---

## Behavior

Notifications stack — each closes independently after its `duration`. There is no limit to the number of simultaneous toasts (configurable in user settings). They never steal NUI focus.
