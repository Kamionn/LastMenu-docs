---
title: Migration guide
description: Migrate from ox_lib, RageUI / RageNativeUI, qb-menu or esx_menu_default to LastMenu — equivalence tables and side-by-side examples.
order: 2
lastUpdated: 2026-04-14
---

## Prerequisites

First: declare LastMenu in client resources that use it.

```lua
-- In each client resource's fxmanifest.lua:
client_scripts { '@LastMenu/client/exports.lua' }
```

```
-- In server.cfg, BEFORE dependent resources:
ensure LastMenu
```

Short reference in code:
```lua
local UI = exports['LastMenu']
```

---

## Key conceptual differences

### No render loop

ox_lib, RageUI and NativeUI require an active loop. LastMenu uses a reactive polling engine — declare what's dynamic, the lib does the rest.

```lua
-- LastMenu: dynamic label without loop
menu:button(function()
    return "Money: " .. GetPlayerMoney() .. " €"
end, { refresh = 500 })
```

### Handles instead of string IDs

```lua
-- ox_lib
lib.registerContext({ id = 'shop', ... })
lib.showContext('shop')

-- LastMenu
local shopMenu = UI:context_build(function(menu) ... end)
shopMenu:open()
shopMenu:close()
```

### Automatic navigation stack

In RageUI / ox_lib, you manually manage which menu is open. In LastMenu, each `UI:context(...)` in a callback pushes to the stack — `Escape` automatically pops.

---

## Migration from ox_lib

### Context menu

| ox_lib | LastMenu |
|---|---|
| `lib.registerContext({ id, title, options })` + `lib.showContext('id')` | `UI:context(fn)` |
| `{ title, description, icon, onSelect }` | `menu:button(label, { icon, hint, cb })` |
| `metadata = { { label, value } }` | `preview = { stats = { { label, value, max } } }` |
| `disabled = true` | `disabled = true` |
| `arrow = true` | `arrow = true` |

```lua
-- ox_lib
lib.registerContext({
    id      = 'garage',
    title   = 'Garage',
    options = {
        {
            title       = 'Repair engine',
            description = 'Requires 500 €',
            icon        = 'wrench',
            onSelect    = function() repairEngine() end,
        },
    },
})
lib.showContext('garage')

-- LastMenu
UI:context(function(menu)
    menu:title("Garage")
    menu:button("Repair engine", {
        icon = "wrench",
        hint = "500 €",
        cb   = function() repairEngine() end,
    })
end)
```

### Input dialog

| ox_lib | LastMenu |
|---|---|
| `lib.inputDialog(title, rows)` | `UI:input_async(fn)` |
| `{ type = 'input', label }` | `b:field(label, { type = 'text' })` |
| `{ type = 'number', min, max }` | `b:field(label, { type = 'number', min, max })` |
| Returns `nil` if cancelled | Returns `nil` if cancelled |

### Alert dialog

| ox_lib | LastMenu |
|---|---|
| `lib.alertDialog({ header, content })` | `UI:alert_async(fn)` |
| Returns `'confirm'` or `'cancel'` | Returns `true` or `false` |

### Notifications

| ox_lib | LastMenu |
|---|---|
| `lib.notify({ description, type, duration })` | `UI:notify(fn)` |
| `type = 'inform'` | `n:type("info")` |

```lua
-- ox_lib
lib.notify({ description = 'Engine repaired.', type = 'success', duration = 3000 })

-- LastMenu
UI:notify(function(n)
    n:message("Engine repaired.")
    n:type("success")
    n:duration(3000)
end)
```

### Target (ox_target)

| ox_target | LastMenu |
|---|---|
| `exports.ox_target:addLocalEntity(entity, opts)` | `UI:target_add_entity(entity, opts)` |
| `exports.ox_target:addModel(models, opts)` | `UI:target_add_model(model, opts)` |
| `exports.ox_target:addSphereZone(opts)` | `UI:target_add_sphere(coords, radius, opts)` |
| `exports.ox_target:addBoxZone(opts)` | `UI:target_add_box(coords, opts)` |
| `exports.ox_target:addPolyZone(opts)` | `UI:target_add_poly(points, opts)` |
| `{ onSelect = fn }` | `{ cb = fn }` |
| `canInteract = function(entity, ...) end` | `condition = function(entity) return bool end` |

### Progress bar

| ox_lib | LastMenu |
|---|---|
| `lib.progressBar({ duration, label })` | `UI:progress(fn)` |
| Blocking (coroutine) | Non-blocking (callbacks) |
| `anim = { dict, clip, flag }` | `b:anim({ dict, clip, flag })` |

---

## Migration from RageUI / RageNativeUI

### Main menu

| RageUI | LastMenu |
|---|---|
| `RageUI.Menu("title", "subtitle")` | `UI:context(fn)` |
| `RageUI.Item("label", "desc")` | `menu:button(label, { hint = desc })` |
| `RageUI.CheckboxItem("label", state)` | `menu:checkbox(label, { default = state })` |
| `RageUI.ListItem("label", list, index)` | `menu:list(label, { items = list, default = index })` |
| `RageUI.SliderItem("label", min, max, val)` | `menu:slider(label, { min, max, default = val })` |
| `RageUI.Render(fn)` — per-frame loop | No loop needed |

```lua
-- RageUI (loop + render)
local menuVisible = false
local menu = RageUI.Menu("Garage", "")

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if menuVisible then
            RageUI.Render(function()
                RageUI.UseMenu(menu, function()
                    local item = RageUI.Item("Réparer", "500 €")
                    if item.Activated then repairEngine() end
                end)
            end)
        end
    end
end)

-- LastMenu (zero loops)
RegisterCommand('garage', function()
    UI:context(function(menu)
        menu:title("Garage")
        menu:button("Réparer", { hint = "500 €", cb = function() repairEngine() end })
    end)
end, false)
```

### RageUI submenus

```lua
-- RageUI
local subMenu = RageUI.Menu("Submenu", "")
local _, activated = RageUI.SubMenu(subMenu, "Go to submenu")
if activated then RageUI.OpenMenu(subMenu) end

-- LastMenu
menu:submenu("Go to submenu", function(sub)
    sub:title("Submenu")
    sub:button("Action", { cb = function() end })
    sub:back()
end)
```

---

## Migration from qb-menu / esx_menu_default

### qb-menu

| qb-menu | LastMenu |
|---|---|
| `exports['qb-menu']:openMenu(items)` | `UI:context(fn)` |
| `{ header, txt, isMenuHeader }` | `menu:header(label)` |
| `{ header, txt, params = { event, args } }` | `menu:button(label, { cb = function() TriggerEvent(...) end })` |
| `{ header, txt, disabled }` | `menu:button(label, { disabled = true })` |

```lua
-- qb-menu
exports['qb-menu']:openMenu({
    { header = "Garage", isMenuHeader = true },
    {
        header = "Repair engine",
        txt    = "Cost: 500 €",
        params = { event = "garage:repairEngine", args = {} },
    },
})

-- LastMenu
UI:context(function(menu)
    menu:header("Garage")
    menu:button("Repair engine", {
        hint = "500 €",
        cb   = function() TriggerEvent("garage:repairEngine") end,
    })
end)
```

---

## Complete equivalence table

| Feature | ox_lib | RageUI | qb-menu | LastMenu |
|---|---|---|---|---|
| Context menu | `registerContext` + `showContext` | `RageUI.Menu` + loop | `openMenu(items)` | `UI:context(fn)` |
| Reusable context | re-show | menu pool | — | `UI:context_build(fn)` |
| Input (callback) | — | — | — | `UI:input(fn)` |
| Input (blocking) | `lib.inputDialog` | — | — | `UI:input_async(fn)` |
| Alert (callback) | — | — | — | `UI:alert(fn)` |
| Alert (blocking) | `lib.alertDialog` | — | — | `UI:alert_async(fn)` |
| Notification | `lib.notify` | — | — | `UI:notify(fn)` |
| Radial menu | `lib.radialMenu` | — | — | `UI:radial(fn)` |
| Progress bar | `lib.progressBar` | — | — | `UI:progress(fn)` |
| Target entity | `ox_target:addLocalEntity` | — | — | `UI:target_add_entity` |
| Target sphere | `ox_target:addSphereZone` | — | — | `UI:target_add_sphere` |
| Real-time reactivity | ❌ | ❌ | ❌ | ✅ |
| Zero dependencies | ❌ | ✅ | ✅ | ✅ |
| Automatic stack | ⚠️ partial | ✅ manual | ❌ | ✅ automatic |
| Controller | ⚠️ | ✅ | ❌ | ✅ |
| CSS theming | ⚠️ | ❌ | ❌ | ✅ |
