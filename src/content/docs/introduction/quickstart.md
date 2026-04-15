---
title: Quick Start
description: Practical examples covering the most common LastMenu use cases.
order: 2
lastUpdated: 2026-04-14
---

## The base pattern

Every LastMenu component follows the same pattern: **export → builder → methods**.

```lua
local UI = exports['LastMenu']

UI:<type>(function(builder)
    builder:<method>(...)
end)
```

No `require`, no framework. Just an export.

---

## Example 1 — Simple garage menu

A context menu with action buttons, a price badge, and a hold-to-confirm action.

```lua
local UI = exports['LastMenu']

RegisterCommand('garage', function()
    UI:context(function(menu)
        menu:title("Garage")
        menu:description("Vehicle maintenance and modifications")

        menu:header("Repairs")
        menu:button("Repair engine", {
            icon         = "wrench",
            badge        = "$500",
            confirm_hold = true,     -- hold 1.5s to confirm
            cb           = function() TriggerServerEvent('garage:repair', 'engine') end,
        })
        menu:button("Repair bodywork", {
            icon  = "car",
            badge = "$200",
            cb    = function() TriggerServerEvent('garage:repair', 'body') end,
        })

        menu:header("Statistics")
        menu:stat("Engine", {
            value   = function() return GetVehicleEngineHealth(GetVehiclePedIsIn(PlayerPedId(), false)) / 10 end,
            max     = 100,
            icon    = "activity",
            suffix  = "%",
            refresh = 1000,
        })
    end)
end, false)
```

---

## Example 2 — Bank transfer form

A blocking multi-field form with NUI-side validation.

```lua
RegisterCommand('transfer', function()
    Citizen.CreateThread(function()
        local values = exports.LastMenu:input_async(function(b)
            b:title("Bank Transfer")
            b:field("Recipient", {
                type        = "text",
                placeholder = "Player name",
                maxlen      = 30,
            })
            b:field("Amount", {
                type = "number",
                min  = 1,
                max  = 100000,
            })
            b:field("Reason", {
                type   = "text",
                maxlen = 50,
            })
        end)

        if not values then return end  -- cancelled by player

        TriggerServerEvent('bank:transfer', values[1], values[2], values[3])
        exports.LastMenu:notify(function(n)
            n:message("Transferred $" .. values[2] .. " to " .. values[1])
            n:type("success")
        end)
    end)
end, false)
```

---

## Example 3 — Quick radial menu

A radial menu accessible at any time, with a vehicle sub-menu.

```lua
local UI = exports['LastMenu']

local quickMenu = UI:radial_build(function(r)
    r:center_label("Quick actions")

    r:button("Heal", {
        icon = "heart",
        cb   = function() TriggerServerEvent('player:heal') end,
    })

    r:button("Vehicle", {
        icon    = "car",
        submenu = function(sub)
            sub:center_label("Vehicle")
            sub:button("Repair",  { icon = "wrench",    cb = function() TriggerServerEvent('vehicle:repair') end })
            sub:button("Flip",    { icon = "rotate-ccw", cb = function() TriggerServerEvent('vehicle:flip')   end })
            sub:button("Clean",   { icon = "droplets",   cb = function() TriggerServerEvent('vehicle:clean')  end })
        end,
    })

    r:button("Missions", {
        icon    = "zap",
        visible = function() return exports['myresource']:hasMissions() end,
        cb      = function() exports['myresource']:openMissions() end,
    })
end)

RegisterCommand('wheel', function() quickMenu.open() end, false)
```

---

## Example 4 — Progress bar with animation

Crafting with ped animation, attached prop, and server-side progress.

```lua
local function startCrafting()
    exports.LastMenu:progress(function(p)
        p:label("Crafting in progress...")
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
                n:message("Crafting complete!")
                n:type("success")
            end)
        end)
        p:onCancel(function()
            exports.LastMenu:notify(function(n)
                n:message("Crafting cancelled.")
                n:type("warning")
            end)
        end)
    end)
end
```

---

## Example 5 — Interactive zone with target

A shop triggered by proximity, with a conditional action (weapon drawn).

```lua
local UI = exports['LastMenu']

local shopId = UI:target_add_sphere(vector3(25.0, -1343.0, 29.5), 2.0, {
    label    = "24/7",
    icon     = "store",
    on_enter = function()
        UI:notify(function(n) n:message("Press E to interact") n:type("info") end)
    end,
    actions = {
        {
            label = "Shop",
            icon  = "shopping-cart",
            cb    = function()
                UI:context(function(menu)
                    menu:title("24/7 — Store")
                    menu:button("Water — $2",  { icon = "droplets", badge = "$2", cb = function() end })
                    menu:button("Chips — $5",  { icon = "package",  badge = "$5", cb = function() end })
                end)
            end,
        },
        {
            label     = "Rob",
            icon      = "alert-triangle",
            condition = function() return IsPedArmed(PlayerPedId(), 6) end,
            cb        = function() TriggerServerEvent('robbery:start') end,
        },
    },
})

-- Always clean up on resource stop
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        UI:target_remove(shopId)
    end
end)
```

---

## Next steps

- Explore all options of the [Context Menu](/docs/composants/context-menu)
- Learn how the [reactivity engine](/docs/avance/reactivite) works
- Customize the appearance with [CSS Theming](/docs/personnalisation/theming)
