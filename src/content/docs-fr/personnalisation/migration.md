---
title: Guide de migration
description: Migrer depuis ox_lib, RageUI / RageNativeUI, qb-menu ou esx_menu_default vers LastMenu — tableaux d'équivalences et exemples côte à côte.
order: 2
lastUpdated: 2026-04-14
---

## Installation préalable

Avant tout : déclare LastMenu dans les ressources clientes qui l'utilisent.

```lua
-- Dans le fxmanifest.lua de chaque ressource cliente :
client_scripts { '@LastMenu/client/exports.lua' }
```

```
-- Dans server.cfg, AVANT les ressources dépendantes :
ensure LastMenu
```

Référence courte dans le code :
```lua
local UI = exports['LastMenu']
```

---

## Différences conceptuelles clés

### Pas de boucle de rendu

ox_lib, RageUI et NativeUI nécessitent une boucle active. LastMenu utilise un moteur de polling réactif — déclare ce qui est dynamique, la lib fait le reste.

```lua
-- LastMenu : label dynamique sans boucle
menu:button(function()
    return "Argent : " .. GetPlayerMoney() .. " €"
end, { refresh = 500 })
```

### Handles plutôt qu'IDs string

```lua
-- ox_lib
lib.registerContext({ id = 'shop', ... })
lib.showContext('shop')

-- LastMenu
local shopMenu = UI:context_build(function(menu) ... end)
shopMenu:open()
shopMenu:close()
```

### Stack de navigation automatique

Chez RageUI / ox_lib, tu gères manuellement quel menu est ouvert. Chez LastMenu, chaque `UI:context(...)` dans un callback pousse sur la stack — `Escape` dépile automatiquement.

---

## Migration depuis ox_lib

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
            title       = 'Réparer le moteur',
            description = 'Nécessite 500 €',
            icon        = 'wrench',
            onSelect    = function() repairEngine() end,
        },
    },
})
lib.showContext('garage')

-- LastMenu
UI:context(function(menu)
    menu:title("Garage")
    menu:button("Réparer le moteur", {
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
| Retourne `nil` si annulé | Retourne `nil` si annulé |

### Alert dialog

| ox_lib | LastMenu |
|---|---|
| `lib.alertDialog({ header, content })` | `UI:alert_async(fn)` |
| Retourne `'confirm'` ou `'cancel'` | Retourne `true` ou `false` |

### Notifications

| ox_lib | LastMenu |
|---|---|
| `lib.notify({ description, type, duration })` | `UI:notify(fn)` |
| `type = 'inform'` | `n:type("info")` |

```lua
-- ox_lib
lib.notify({ description = 'Moteur réparé.', type = 'success', duration = 3000 })

-- LastMenu
UI:notify(function(n)
    n:message("Moteur réparé.")
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
| Bloquant (coroutine) | Non-bloquant (callbacks) |
| `anim = { dict, clip, flag }` | `b:anim({ dict, clip, flag })` |

---

## Migration depuis RageUI / RageNativeUI

### Menu principal

| RageUI | LastMenu |
|---|---|
| `RageUI.Menu("title", "subtitle")` | `UI:context(fn)` |
| `RageUI.Item("label", "desc")` | `menu:button(label, { hint = desc })` |
| `RageUI.CheckboxItem("label", state)` | `menu:checkbox(label, { default = state })` |
| `RageUI.ListItem("label", list, index)` | `menu:list(label, { items = list, default = index })` |
| `RageUI.SliderItem("label", min, max, val)` | `menu:slider(label, { min, max, default = val })` |
| `RageUI.Render(fn)` — boucle par frame | Aucune boucle nécessaire |

```lua
-- RageUI (boucle + render)
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

-- LastMenu (zéro boucle)
RegisterCommand('garage', function()
    UI:context(function(menu)
        menu:title("Garage")
        menu:button("Réparer", { hint = "500 €", cb = function() repairEngine() end })
    end)
end, false)
```

### Sous-menus RageUI

```lua
-- RageUI
local subMenu = RageUI.Menu("Sous-menu", "")
local _, activated = RageUI.SubMenu(subMenu, "Aller au sous-menu")
if activated then RageUI.OpenMenu(subMenu) end

-- LastMenu
menu:submenu("Aller au sous-menu", function(sub)
    sub:title("Sous-menu")
    sub:button("Action", { cb = function() end })
    sub:back()
end)
```

---

## Migration depuis qb-menu / esx_menu_default

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
        header = "Réparer moteur",
        txt    = "Coût : 500 €",
        params = { event = "garage:repairEngine", args = {} },
    },
})

-- LastMenu
UI:context(function(menu)
    menu:header("Garage")
    menu:button("Réparer moteur", {
        hint = "500 €",
        cb   = function() TriggerEvent("garage:repairEngine") end,
    })
end)
```

---

## Tableau d'équivalences complet

| Fonctionnalité | ox_lib | RageUI | qb-menu | LastMenu |
|---|---|---|---|---|
| Context menu | `registerContext` + `showContext` | `RageUI.Menu` + boucle | `openMenu(items)` | `UI:context(fn)` |
| Context réutilisable | re-show | pool de menus | — | `UI:context_build(fn)` |
| Input (callback) | — | — | — | `UI:input(fn)` |
| Input (bloquant) | `lib.inputDialog` | — | — | `UI:input_async(fn)` |
| Alert (callback) | — | — | — | `UI:alert(fn)` |
| Alert (bloquant) | `lib.alertDialog` | — | — | `UI:alert_async(fn)` |
| Notification | `lib.notify` | — | — | `UI:notify(fn)` |
| Radial menu | `lib.radialMenu` | — | — | `UI:radial(fn)` |
| Progress bar | `lib.progressBar` | — | — | `UI:progress(fn)` |
| Target entity | `ox_target:addLocalEntity` | — | — | `UI:target_add_entity` |
| Target sphere | `ox_target:addSphereZone` | — | — | `UI:target_add_sphere` |
| Réactivité temps réel | ❌ | ❌ | ❌ | ✅ |
| Zéro dépendance | ❌ | ✅ | ✅ | ✅ |
| Stack automatique | ⚠️ partiel | ✅ manuel | ❌ | ✅ automatique |
| Manette | ⚠️ | ✅ | ❌ | ✅ |
| Theming CSS | ⚠️ | ❌ | ❌ | ✅ |
