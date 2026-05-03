---
title: Target System
description: ox_target / qtarget replacement — detects aimed entity or zone and displays interaction menu. Supports entities, models, spheres, boxes and polygons.
order: 7
lastUpdated: 2026-04-20
---

## How it works

A background thread runs at **10 Hz** (100ms). When the player aims at an entity or enters a registered zone:

1. A **passive reticle** appears in the center of the screen.
2. Player presses the **target key** (default: Left Ctrl / `INPUT_DUCK`) → the **action menu** opens.
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
| `opts.actions` | `table` | `{}` | Array of action objects (or use the builder API) |
| `opts.on_enter` | `function` | `nil` | Called once when player enters zone |
| `opts.on_leave` | `function` | `nil` | Called once when player leaves zone |

---

### Model — all matching entities

```lua
local id = exports.LastMenu:target_add_model(model, opts)
```

| Field | Type | Description |
|---|---|---|
| `model` | `string\|number\|nil` | Model name, hash, or `nil` for **all vehicles** |

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

Axis-aligned rectangular zone, rotatable by heading.

```lua
local id = exports.LastMenu:target_add_box(coords, opts)
```

| Field | Type | Default | Description |
|---|---|---|---|
| `opts.width` | `number` | `2.0` | Total width on local X axis |
| `opts.length` | `number` | `2.0` | Total length on local Y axis |
| `opts.heading` | `number` | `0.0` | Rotation in degrees (GTA: clockwise from North) |

> `width` and `length` are not available through the builder API. Use the table form when you need specific dimensions.

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

> `minZ` / `maxZ` are not available through the builder API. Use the table form when you need Z constraints.

**Example — L-shaped floor plan:**

```lua
local storeFloor = {
    vector2(312.0, -780.0),
    vector2(320.0, -780.0),
    vector2(320.0, -795.0),
    vector2(328.0, -795.0),
    vector2(328.0, -808.0),
    vector2(312.0, -808.0),
}

local storeId = exports.LastMenu:target_add_poly(storeFloor, {
    minZ     = 28.5,
    maxZ     = 32.0,
    label    = "24/7 Store",
    icon     = "store",
    on_enter = function()
        exports.LastMenu:notify(function(n) n:message("Welcome!"); n:type("info") end)
    end,
    on_leave = function()
        exports.LastMenu:notify(function(n) n:message("Thanks for visiting."); n:type("info") end)
    end,
    actions  = {
        { label = "Shop",        icon = "shopping-cart", cb = function() end },
        { label = "Rob cashier", icon = "alert-triangle",
          condition = function() return IsPedArmed(PlayerPedId(), 6) end,
          cb = function() TriggerServerEvent("crime:robbery") end },
    },
})

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    exports.LastMenu:target_remove(storeId)
end)
```

---

## Action object

Each entry in `opts.actions` supports:

| Field | Type | Description |
|---|---|---|
| `label` | `string` | Button text |
| `icon` | `string` | Lucide icon |
| `color` | `string` | Accent color (hex) applied to icon and optional gradient |
| `gradient` | `bool` | Gradient background on the action button |
| `badge` | `string` | Small text badge on the right |
| `cb` | `function(entity)` | Called on click. `entity` = entity handle (or `nil` for zones) |
| `condition` | `bool\|function(entity)→bool` | Hide the action when `false` (preferred alias for `visible`) |
| `visible` | `bool\|function(entity)→bool` | Hide the action when `false` |
| `disabled` | `bool\|function(entity)→bool` | Show grayed-out, no callback |
| `confirm_hold` | `number\|true` | Hold-to-confirm duration in ms |
| `cooldown` | `number` | Recharge delay in ms after click |
| `persist_key` | `string` | Stable localStorage key for cooldown persistence |
| `keep_open` | `bool` | Keep the target menu open after callback fires |

`condition` takes priority over `visible` when both are set.

```lua
actions = {
    {
        label   = "Search body",
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

## Builder API

The `opts` parameter accepts either a **table** (classic) or a **builder function** (recommended). The builder is auto-detected — same pattern as `LM:context()`.

```lua
LM:target_add_model("mp_m_freemode_01", function(t)
    t:label("Player")
    t:icon("user")
    t:distance(3.0)
    t:button("Interact", { icon = "hand", cb = function(entity) end })
end)
```

### Header methods

| Method | Type | Default | Description |
|---|---|---|---|
| `t:label(str)` | `string` | `"Interact"` | Title of the action menu |
| `t:icon(str)` | `string` | `"eye"` | Lucide icon shown in the reticle |
| `t:distance(num)` | `number` | `3.0` | Max distance in metres |
| `t:banner(url)` | `string` | `nil` | Image/GIF URL displayed at the top of the menu |
| `t:on_enter(fn)` | `function()` | `nil` | Called once when the player enters the zone |
| `t:on_leave(fn)` | `function()` | `nil` | Called once when the player leaves the zone |

### `t:button(label, opts)`

Simple action. Callback receives `entity` (handle, or `nil` for zone-based targets).

```lua
t:button("Repair", {
    icon         = "wrench",
    gradient     = true,
    confirm_hold = 2000,
    cooldown     = 60000,
    condition    = function() return isOnDuty end,
    cb           = function(entity) repairVehicle(entity) end,
})
```

### `t:toggle(label, opts)`

Persistent ON/OFF button. Callback receives `entity, boolean_value`.

```lua
t:toggle("Lock", {
    icon    = "lock",
    default = false,
    cb      = function(entity, val)
        SetVehicleDoorsLocked(entity, val and 2 or 1)
    end,
})
```

### `t:checkbox(label, opts)`

Same interface as `toggle` but different visual rendering.

### `t:slider(label, opts)`

Numeric slider. Callback receives `entity, numeric_value`.

```lua
t:slider("Fuel", {
    icon    = "fuel",
    min     = 0,
    max     = 100,
    step    = 5,
    default = 50,
    suffix  = "%",
    cb      = function(entity, val)
        -- SetVehicleFuelLevel(entity, val * 0.65)
    end,
})
```

### `t:separator()`

Visual divider between action groups.

### `t:group(label, opts, fn)`

Groups actions inside a collapsible accordion. All action types are available inside a group.

```lua
t:group("Services", { icon = "tool" }, function(g)
    g:button("Clean",          { icon = "droplets",         cb = cleanVehicle  })
    g:button("Inflate tyres",  { icon = "circle-dot",       cb = inflateTyres  })
    g:button("Charge battery", { icon = "battery-charging", cb = chargeBattery })
    -- g:toggle / g:checkbox / g:slider also available
end)
```

| Option | Type | Description |
|---|---|---|
| `icon` | `string` | Icon for the group header |
| `open` | `bool` | Expanded by default (`false`) |

### `t:submenu(label, opts)`

Arrow `→` button that calls a function **without closing** the target menu.

```lua
t:submenu("Mechanic menu", {
    icon = "hard-hat",
    cb   = function(entity) openMechanicRadial(entity) end,
})
```

The target menu stays open. Use `LM:context()` or `LM:radial()` inside the callback for a sub-level of actions.

> **Difference from `button`:** a `button` closes the target menu before firing its callback. A `submenu` keeps it open.

### Method availability

| Method | `t:` (root) | `g:` (group) |
|---|---|---|
| `button` | ✓ | ✓ |
| `toggle` | ✓ | ✓ |
| `checkbox` | ✓ | ✓ |
| `slider` | ✓ | ✓ |
| `separator` | ✓ | — |
| `group` | ✓ | — |
| `submenu` | ✓ | — |
| `label` / `icon` / `distance` / `banner` | ✓ | — |
| `on_enter` / `on_leave` | ✓ | — |

---

## Removal

```lua
-- Remove one registration
exports.LastMenu:target_remove(id)

-- Remove all registrations
exports.LastMenu:target_clear()
```

> Always clean up on resource stop:
>
> ```lua
> AddEventHandler("onResourceStop", function(res)
>     if res == GetCurrentResourceName() then
>         exports.LastMenu:target_remove(myId)
>     end
> end)
> ```

Registrations are also automatically removed when the resource that created them stops.

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

The debug thread sleeps at 500ms when disabled — no production cost.

---

## Full example

```lua
local LM = exports.LastMenu

LM:target_add_model(nil, function(t)  -- nil = all vehicles
    t:label("Vehicle")
    t:icon("car")
    t:distance(4.0)

    t:button("Repair", {
        icon         = "wrench",
        gradient     = true,
        confirm_hold = 2000,
        cooldown     = 60000,
        condition    = function() return isOnDuty end,
        cb           = function(entity) repairVehicle(entity) end,
    })

    t:button("Inspect / Estimate", {
        icon = "clipboard-list",
        cb   = function(entity) openDiagnostic(entity) end,
    })

    t:separator()

    t:group("Services", { icon = "tool" }, function(g)
        g:button("Clean", {
            icon      = "droplets",
            condition = function() return isOnDuty end,
            cb        = function(entity) cleanVehicle(entity) end,
        })
        g:button("Inflate tyres", {
            icon = "circle-dot",
            cb   = function(entity) inflateAllTyres(entity) end,
        })
    end)

    t:group("Options", { icon = "settings-2" }, function(g)
        g:toggle("Lock", {
            icon    = "lock",
            default = false,
            cb      = function(entity, val)
                SetVehicleDoorsLocked(entity, val and 2 or 1)
            end,
        })
        g:slider("Fuel", {
            icon = "fuel", min = 0, max = 100, step = 5, suffix = "%",
            cb   = function(entity, val) end,
        })
    end)

    t:submenu("Mechanic menu", {
        icon = "hard-hat",
        cb   = function(entity) openMechanicRadial(entity) end,
    })
end)
```
