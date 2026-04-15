---
title: Radial Menu
description: Circular action wheel — ideal for quick shortcuts accessible by mouse, keyboard or controller.
order: 2
lastUpdated: 2026-04-14
---

## Opening

```lua
exports.LastMenu:radial(function(r)
    r:center_label("Quick hub")
    r:button("Garage",   { icon = "car",          cb = openGarage   })
    r:button("Hospital", { icon = "plus-circle",  cb = openHospital })
    r:button("Missions", { icon = "zap",           cb = openMissions })
end)
```

The center sector displays `center_label` when no sector is hovered.

---

## Reusable menu

Use `radial_build` to build an instance once and reopen it at will:

```lua
local radial = exports.LastMenu:radial_build(function(r)
    r:button("Action A", { icon = "check", cb = function() end })
    r:button("Action B", { icon = "x",     cb = function() end })
end)

RegisterCommand('wheel', function() radial.open()  end, false)
RegisterCommand('closewheel', function() radial.close() end, false)
```

---

## Menu options

| Method | Description |
|---|---|
| `r:center_label(str)` | Text displayed in the central ring at rest |

## Button options

| Field | Type | Default | Description |
|---|---|---|---|
| `icon` | `string` | — | Lucide icon name |
| `cb` | `function()` | — | Called on selection |
| `keep_open` | `bool` | `false` | Don't close radial after callback |
| `submenu` | `function(r)` | `nil` | Opens nested radial on click |
| `visible` | `bool\|function() → bool` | `true` | Hides and removes the sector |
| `disabled` | `bool\|function() → bool` | `false` | Grayed out, no callback |
| `refresh` | `number` | `250` | Polling interval (ms) for `visible`/`disabled` |

---

## Conditional button (reactivity)

Shows "Exit vehicle" button only when player is in a vehicle:

```lua
exports.LastMenu:radial(function(r)
    r:center_label("Actions")

    r:button("Exit vehicle", {
        icon    = "log-out",
        visible = function()
            return GetVehiclePedIsIn(PlayerPedId(), false) ~= 0
        end,
        refresh = 500,
        cb = function()
            TaskLeaveAnyVehicle(PlayerPedId(), 0, 16)
        end,
    })

    r:button("Heal", {
        icon = "heart",
        cb   = function() TriggerServerEvent('player:heal') end,
    })
end)
```

---

## Sub-radials

Nest radial menus with `button.submenu`. The parent radial is stacked and restored on `Escape`:

```lua
exports.LastMenu:radial(function(r)
    r:center_label("Actions")

    r:button("Vehicle", {
        icon    = "car",
        submenu = function(sub)
            sub:center_label("Vehicle")
            sub:button("Repair",  { icon = "wrench",   cb = repairVehicle })
            sub:button("Clean", { icon = "droplets", cb = cleanVehicle  })
        end,
    })

    r:button("Player", {
        icon    = "user",
        submenu = function(sub)
            sub:center_label("Player")
            sub:button("Heal", { icon = "heart", cb = healPlayer })
        end,
    })
end)
```

> With `submenu`, `keep_open = true` is set automatically — no need to specify it manually.

---

## Controls

| Input | Action |
|---|---|
| Mouse hover | Highlights sector |
| Left click | Confirms selection |
| Left stick (controller) | Highlights by direction |
| A / Cross button (controller) | Confirms selection |
| `Escape` | Closes without action |

---

## Best practices

**`visible = false`** removes the sector and redistributes the arc geometry. Use `disabled = true` if you want to keep the sector visible but inactive (stable layout).

**Button limit** — up to about 12 buttons display properly. Beyond that, sectors become too narrow — consider sub-radials or a context menu.

The `visible`/`disabled` watchers use the same adaptive polling engine as context menus (backoff on stability, reset on change).
