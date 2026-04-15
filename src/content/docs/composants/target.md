---
title: Target System
description: ox_target / qtarget replacement — detects aimed entity or zone and displays interaction menu. Supports entities, models, spheres, boxes and polygons.
order: 7
lastUpdated: 2026-04-14
---

## How it works

A background thread runs at **10 Hz** (100ms). When the player aims at an entity or enters a registered zone:

1. A **passive reticle** appears in the center of the screen.
2. Player presses **E** (`INPUT_CONTEXT`) → the **action menu** opens.
3. Selecting an action triggers the callback; `Escape` or ✕ button closes the menu.

When no registrations exist, the thread sleeps at **1 Hz** (no CPU cost).

---

## Registration types

### Entity — specific handle

```lua
local id = exports.LastMenu:target_add_entity(entity, opts)
```

| Field | Type | Default | Description |
|---|---|---|---|
| `entity` | `number` | — | Entity handle |
| `opts.label` | `string` | `"Interact"` | Action menu header label |
| `opts.icon` | `string` | `"eye"` | Lucide icon in reticle |
| `opts.distance` | `number` | `3.0` | Max distance in meters |
| `opts.actions` | `table` | `{}` | Array of action objects (see below) |
| `opts.on_enter` | `function` | `nil` | Called once when player enters zone |
| `opts.on_leave` | `function` | `nil` | Called once when player leaves zone |

---

### Model — all matching entities

```lua
local id = exports.LastMenu:target_add_model(model, opts)
```

| Field | Type | Description |
|---|---|---|
| `model` | `string\|number\|nil` | Model name, hash, or `nil` for **all peds** |

Other fields are identical to `target_add_entity`.

---

### Sphere zone

```lua
local id = exports.LastMenu:target_add_sphere(coords, radius, opts)
```

| Field | Type | Default |
|---|---|---|
| `coords` | `vector3` | — |
| `radius` | `number` | `2.0` |

---

### Rectangular zone (box)

Rectangular zone aligned on an axis, rotatable by heading.

```lua
local id = exports.LastMenu:target_add_box(coords, opts)
```

| Field | Type | Default | Description |
|---|---|---|---|
| `opts.width` | `number` | `2.0` | Total width on local X axis |
| `opts.length` | `number` | `2.0` | Total length on local Y axis |
| `opts.heading` | `number` | `0.0` | Rotation in degrees (GTA: clockwise from North) |

---

### Polygonal zone

2D polygon with optional Z bounds.

```lua
local id = exports.LastMenu:target_add_poly(points, opts)
```

| Field | Type | Default | Description |
|---|---|---|---|
| `points` | `vector2[]\|vector3[]` | — | Vertices defining the polygon |
| `opts.minZ` | `number` | `-math.huge` | Lower Z bound |
| `opts.maxZ` | `number` | `math.huge` | Upper Z bound |

**Example — L-shaped floor plan:**

```lua
local UI = exports['LastMenu']

local storeFloor = {
    vector2(312.0, -780.0),
    vector2(320.0, -780.0),
    vector2(320.0, -795.0),
    vector2(328.0, -795.0),
    vector2(328.0, -808.0),
    vector2(312.0, -808.0),
}

local storeId = UI:target_add_poly(storeFloor, {
    minZ    = 28.5,
    maxZ    = 32.0,
    label   = "Store",
    icon    = "store",
    on_enter = function()
        UI:notify(function(n) n:message("You enter the store.") n:type("info") end)
    end,
    on_leave = function()
        UI:notify(function(n) n:message("You leave the store.") n:type("info") end)
    end,
    actions = {
        {
            label = "Talk to cashier",
            icon  = "message-square",
            cb    = function()
                UI:context(function(menu)
                    menu:title("Cashier")
                    menu:button("Buy something", { icon = "shopping-cart", cb = function() end })
                end)
            end,
        },
        {
            label    = "Rob the register",
            icon     = "alert-triangle",
            visible  = function() return IsPedArmed(PlayerPedId(), 6) end,
            cb       = function() TriggerServerEvent('robbery:start') end,
        },
    },
})
```

---

## Action structure

| Field | Type | Description |
|---|---|---|
| `label` | `string` | Button text |
| `icon` | `string` | Lucide icon |
| `cb` | `function(entity)` | Called on click. `entity` = raycast handle (or `nil` for zones) |
| `visible` | `bool\|function(entity) → bool` | Hides action if `false` |
| `condition` | `bool\|function(entity) → bool` | Alias for `visible` — preferred for semantic clarity |
| `disabled` | `bool\|function(entity) → bool` | Shown grayed out, no callback |

`visible`, `condition` and `disabled` accept **static booleans** or **callables** — evaluated each time the menu opens. `condition` takes priority over `visible` if both are defined.

```lua
actions = {
    {
        label   = "Search",
        icon    = "search",
        visible = function(ent) return IsPedDeadOrDying(ent, true) end,
        cb      = function(ent) print("Searched ped " .. ent) end,
    },
    {
        label    = "Heal",
        icon     = "plus-circle",
        disabled = function(ent) return GetEntityHealth(ent) >= 200 end,
        cb       = function(ent) print("Healed ped " .. ent) end,
    },
}
```

---

## Removal

```lua
-- Remove a registration
exports.LastMenu:target_remove(id)

-- Remove all registrations
exports.LastMenu:target_clear()
```

> **Always clean up on resource stop** to avoid ghost zone leaks:
>
> ```lua
> AddEventHandler('onResourceStop', function(res)
>     if res == GetCurrentResourceName() then
>         exports.LastMenu:target_remove(myId)
>     end
> end)
> ```

---

## Registration merging

When multiple registrations match simultaneously, their actions are **merged** into a single menu. Header label priority: `entity > model > zone`.

---

## Visual debug

Enable `Config.debugTarget = true` in `client/config.lua` to visualize all zones in-game:

| Zone type | Visualization |
|---|---|
| `sphere` | Blue translucent sphere |
| `box` | Marker + corner lines |
| `poly` | Outline connecting all vertices |

```lua
Config.debugTarget = true  -- in client/config.lua
```

The debug thread sleeps at 500ms when disabled — no production cost.
