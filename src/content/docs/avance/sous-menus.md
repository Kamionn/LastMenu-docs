---
title: Sub-menus & Navigation Stack
description: Nest context menus, use submenu/back helpers, and understand how the navigation stack works automatically.
order: 3
lastUpdated: 2026-04-14
---

## How the stack works

Each `UI:context(fn)` call in a callback **pushes** a menu onto the NUI stack. Pressing `Escape` (or clicking the back button) **pops** the top menu and restores the previous one.

You never have to manage this stack manually — LastMenu handles it for you.

```
[Main menu]  ← stack level 1
    └─ [Settings submenu]  ← stack level 2 (opened from a callback)
           └─ [Audio sub-submenu]  ← stack level 3
```

Pressing Escape from level 3 → back to level 2 → back to level 1.

---

## Manual sub-menu (long method)

```lua
UI:context(function(menu)
    menu:title("Main menu")

    menu:button("Advanced options", {
        icon      = "settings",
        arrow     = true,
        keep_open = true,   -- REQUIS : garde le parent ouvert
        cb        = function()
            UI:context(function(sub)
                sub:title("Options avancées")
                sub:animation("slideRight")
                sub:button("Option A", { cb = function() end })
                sub:button("Retour",   { icon = "arrow-left", cb = function() end })
            end)
        end,
    })
end)
```

> `keep_open = true` est **indispensable** sur le bouton parent. Sans ça, le menu parent se fermerait avant l'ouverture du sous-menu, cassant la stack.

---

## `submenu` and `back` helpers (v1.0.0)

These shortcuts reduce boilerplate:

```lua
UI:context(function(menu)
    menu:title("Main menu")

    -- menu:submenu(label, builderFn, opts)
    -- equivalent to a keep_open button that opens a sub-context
    menu:submenu("Settings", function(sub)
        sub:title("Settings")
        sub:button("Audio",  { icon = "volume-2", cb = function() end })
        sub:button("Video",  { icon = "monitor",  cb = function() end })

        -- sub:back(label, opts) — closes this menu and returns to parent
        sub:back("Back", { icon = "arrow-left" })
    end, { icon = "settings" })

    menu:submenu("Vehicle", function(sub)
        sub:title("Vehicle")
        sub:button("Réparer",   { icon = "wrench",   cb = function() end })
        sub:button("Nettoyer",  { icon = "droplets", cb = function() end })
        sub:back("Retour")
    end, { icon = "car" })
end)
```

### `menu:back(label, opts)`

Equivalent to a button whose callback calls `Stack.pop()`. Pass `opts.cb` to execute cleanup logic **before** popping:

```lua
sub:back("Back", {
    icon = "arrow-left",
    cb   = function()
        -- Optional cleanup before returning
        cleanup()
    end
})
```

---

## Deep nesting

The stack supports arbitrary depth. Example: menu → submenu → confirmation:

```lua
UI:context(function(menu)
    menu:title("Garage")

    menu:submenu("Available cars", function(sub)
        sub:title("Available cars")

        sub:button("Infernus Classic", {
            icon      = "car",
            badge     = "250 000 €",
            keep_open = true,
            cb        = function()
                exports.LastMenu:alert_async and
                Citizen.CreateThread(function()
                    local ok = exports.LastMenu:alert_async(function(b)
                        b:title("Buy Infernus Classic?")
                        b:message("Cost: 250 000 €")
                        b:confirm_label("Buy")
                        b:cancel_label("Cancel")
                    end)
                    if ok then TriggerServerEvent('garage:buy', 'infernus2') end
                end)
            end,
        })

        sub:back("Back")
    end, { icon = "layout-grid" })
end)
```

---

## Programmatic navigation

```lua
-- Fermer le menu du dessus (équivalent à Escape)
exports.LastMenu:lastmenu_back()
```

Depuis v1.1, l'export s'appelle `lastmenu_back` (et non `back`) pour éviter les collisions avec d'autres ressources. La méthode builder `menu:back()` reste inchangée.

---

## Menus réutilisables et stack

`context_build` construit l'instance une fois. Chaque `open()` pousse sur la stack :

```lua
local shopMenu = UI:context_build(function(menu)
    menu:title("Boutique")
    menu:button("Acheter item — 50 €", {
        icon = "shopping-cart",
        cb   = function() print("acheté") end,
    })
    menu:button("Fermer", { icon = "x", cb = function() end })
end)

RegisterCommand('boutique', function()
    shopMenu:open()
end, false)
```

> **Note :** les callbacks sont enregistrés une seule fois. Les watchers réactifs redémarrent à chaque `open()`.
