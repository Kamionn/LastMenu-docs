---
title: Quick Start
description: Exemples concrets couvrant les cas d'usage les plus fréquents de LastMenu.
order: 2
lastUpdated: 2026-04-14
---

## Le pattern de base

Chaque composant LastMenu suit le même pattern : **export → builder → méthodes**.

```lua
local UI = exports['LastMenu']

UI:<type>(function(builder)
    builder:<méthode>(...)
end)
```

Pas de `require`, pas de framework. Juste un export.

---

## Cas 1 — Menu de garage simple

Un menu contextuel avec des boutons d'action, un badge de prix, et une confirmation avant achat.

```lua
local UI = exports['LastMenu']

RegisterCommand('garage', function()
    UI:context(function(menu)
        menu:title("Garage")
        menu:description("Entretien et modifications de véhicule")

        menu:header("Réparations")
        menu:button("Réparer le moteur", {
            icon    = "wrench",
            badge   = "500 €",
            confirm_hold = true,     -- tenir 1,5s pour confirmer
            cb      = function() TriggerServerEvent('garage:repair', 'engine') end,
        })
        menu:button("Réparer la carrosserie", {
            icon  = "car",
            badge = "200 €",
            cb    = function() TriggerServerEvent('garage:repair', 'body') end,
        })

        menu:header("Statistiques")
        menu:stat("Moteur", {
            value  = function() return GetVehicleEngineHealth(GetVehiclePedIsIn(PlayerPedId(), false)) / 10 end,
            max    = 100,
            icon   = "activity",
            suffix = "%",
            refresh = 1000,
        })
    end)
end, false)
```

---

## Cas 2 — Formulaire de transfert bancaire

Un formulaire multi-champs bloquant avec validation côté NUI.

```lua
RegisterCommand('virement', function()
    Citizen.CreateThread(function()
        local values = exports.LastMenu:input_async(function(b)
            b:title("Virement bancaire")
            b:field("Destinataire", {
                type        = "text",
                placeholder = "Nom du joueur",
                maxlen      = 30,
            })
            b:field("Montant", {
                type = "number",
                min  = 1,
                max  = 100000,
            })
            b:field("Motif", {
                type   = "text",
                maxlen = 50,
            })
        end)

        if not values then return end  -- annulé par le joueur

        TriggerServerEvent('bank:transfer', values[1], values[2], values[3])
        exports.LastMenu:notify(function(n)
            n:message("Virement de " .. values[2] .. " € envoyé à " .. values[1])
            n:type("success")
        end)
    end)
end, false)
```

---

## Cas 3 — Menu radial rapide

Un menu radial accessible à tout moment, avec un sous-menu pour les actions véhicule.

```lua
local UI = exports['LastMenu']

local quickMenu = UI:radial_build(function(r)
    r:center_label("Actions rapides")

    r:button("Soigner", {
        icon = "heart",
        cb   = function() TriggerServerEvent('player:heal') end,
    })

    r:button("Véhicule", {
        icon    = "car",
        submenu = function(sub)
            sub:center_label("Véhicule")
            sub:button("Réparer",   { icon = "wrench",   cb = function() TriggerServerEvent('vehicle:repair')  end })
            sub:button("Retourner", { icon = "rotate-ccw", cb = function() TriggerServerEvent('vehicle:flip')   end })
            sub:button("Nettoyer",  { icon = "droplets", cb = function() TriggerServerEvent('vehicle:clean')  end })
        end,
    })

    r:button("Missions", {
        icon    = "zap",
        visible = function() return exports['myresource']:hasMissions() end,
        cb      = function() exports['myresource']:openMissions() end,
    })
end)

RegisterCommand('roue', function() quickMenu.open() end, false)
```

---

## Cas 4 — Barre de progression avec animation

Crafting avec animation ped, prop attaché, et progression serveur.

```lua
local function startCrafting()
    exports.LastMenu:progress(function(p)
        p:label("Fabrication en cours...")
        p:icon("hammer")
        p:duration(8000)
        p:cancel(true)
        p:anim({
            dict  = "amb@world_human_welding@male@base",
            clip  = "base",
            flag  = 1,
        })
        p:prop({
            model  = "prop_tool_torch",
            bone   = 57005,
            offset = vector3(0.12, 0.03, 0.0),
            rot    = vector3(0.0, 0.0, 0.0),
        })
        p:onComplete(function()
            TriggerServerEvent('crafting:complete')
            exports.LastMenu:notify(function(n)
                n:message("Fabrication terminée !")
                n:type("success")
            end)
        end)
        p:onCancel(function()
            exports.LastMenu:notify(function(n)
                n:message("Fabrication annulée.")
                n:type("warning")
            end)
        end)
    end)
end
```

---

## Cas 5 — Zone interactive avec target

Un magasin déclenché par proximité, avec action conditionnelle (arme dégainée).

```lua
local UI = exports['LastMenu']

local shopId = UI:target_add_sphere(vector3(25.0, -1343.0, 29.5), 2.0, {
    label   = "24/7",
    icon    = "store",
    on_enter = function()
        UI:notify(function(n) n:message("Appuyez sur E pour interagir") n:type("info") end)
    end,
    actions = {
        {
            label = "Acheter",
            icon  = "shopping-cart",
            cb    = function()
                UI:context(function(menu)
                    menu:title("24/7 — Achats")
                    menu:button("Eau — 2 €",  { icon = "droplets", badge = "2 €",  cb = function() end })
                    menu:button("Chips — 5 €", { icon = "package",  badge = "5 €",  cb = function() end })
                end)
            end,
        },
        {
            label     = "Braquer",
            icon      = "alert-triangle",
            condition = function() return IsPedArmed(PlayerPedId(), 6) end,
            cb        = function() TriggerServerEvent('robbery:start') end,
        },
    },
})

-- Toujours nettoyer à l'arrêt de la ressource
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        UI:target_remove(shopId)
    end
end)
```

---

## Prochaines étapes

- Explore les options complètes du [Context Menu](/docs/composants/context-menu)
- Apprends comment fonctionne le [moteur de réactivité](/docs/avance/reactivite)
- Personnalise l'apparence avec la [Thématisation CSS](/docs/personnalisation/theming)
