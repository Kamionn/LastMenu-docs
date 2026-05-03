---
title: Garage
description: Complete garage system — tabbed menu, reactive vehicle stats, sub-menu actions, repair progress bar with animation and target zone.
order: 2
lastUpdated: 2026-04-20
---

Full FiveM resource example. Demonstrates:

- `tab` — "My Garage" / "Buy" / "Options" tabs
- `stat` with reactive `value` and `color`
- `button` with `preview` panel
- `alert` — purchase and repair confirmations
- `progress` — repair bar with ped animation and prop
- `notify` — result feedback
- `target_add_sphere` — garage interaction zone

```lua
local LM = exports.LastMenu

-- ── Fake data (replace with your server data) ─────────────────────────────────

local playerVehicles = {
    { model = "adder",    label = "Adder",    fuel = 82, bodyHealth = 1000 },
    { model = "zentorno", label = "Zentorno", fuel = 41, bodyHealth = 740  },
    { model = "t20",      label = "T20",      fuel = 95, bodyHealth = 980  },
}

local vehiclesForSale = {
    { model = "sultan",   label = "Sultan RS",    price = 12000  },
    { model = "elegy2",   label = "Elegy RH8",    price = 95000  },
    { model = "banshee2", label = "Banshee 900R", price = 565000 },
}

local garageCoords = vector3(215.0, -810.0, 30.0)

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function healthToColor(hp)
    local pct = hp / 1000
    if pct > 0.75 then return "#4ade80" end
    if pct > 0.40 then return "#facc15" end
    return "#f87171"
end

local function formatPrice(n) return string.format("%d $", n) end

-- ── Vehicle sub-menu ──────────────────────────────────────────────────────────

local function openVehicleMenu(vehicle)
    LM:context(function(menu)
        menu:title(vehicle.label)
        menu:description("Vehicle options")
        menu:animation("slideRight")

        menu:stat("Fuel", {
            value   = function() return vehicle.fuel end,
            max     = 100,
            suffix  = "%",
            color   = "auto",
            refresh = 1000,
        })

        menu:stat("Body", {
            value   = function() return vehicle.bodyHealth end,
            max     = 1000,
            color   = function() return healthToColor(vehicle.bodyHealth) end,
            refresh = 800,
        })

        menu:separator()

        menu:button("Retrieve vehicle", {
            icon  = "car",
            arrow = true,
            cb = function()
                LM:alert(function(a)
                    a:title("Retrieve vehicle")
                    a:message("Spawn the " .. vehicle.label .. " in front of the garage?")
                    a:confirm("Retrieve", function()
                        LM:progress(function(p)
                            p:label("Retrieving vehicle…")
                            p:duration(3000)
                            p:icon("car")
                            p:anim({
                                dict = "anim@heists@ornate_bank@security_guard",
                                clip = "stand_fire_loop_pistol",
                                flag = 1,
                            })
                            p:confirm(function()
                                -- In production: RequestModel() + CreateVehicle()
                                LM:notify(function(n)
                                    n:message(vehicle.label .. " retrieved!")
                                    n:type("success"); n:duration(4000)
                                end)
                            end)
                        end)
                    end)
                    a:cancel("Cancel")
                end)
            end,
        })

        menu:button("Repair", {
            icon     = "wrench",
            disabled = function() return vehicle.bodyHealth >= 1000 end,
            badge    = function()
                if vehicle.bodyHealth >= 1000 then return "OK" end
                return string.format("%d%%", math.floor(vehicle.bodyHealth / 10))
            end,
            refresh = 1000,
            cb = function()
                local cost = math.floor((1000 - vehicle.bodyHealth) * 0.8)
                LM:alert(function(a)
                    a:title("Repair vehicle")
                    a:message(string.format("Repair the %s for %s?", vehicle.label, formatPrice(cost)))
                    a:confirm("Pay & Repair", function()
                        LM:progress(function(p)
                            p:label("Repairing…")
                            p:duration(5000)
                            p:cancelable(true)
                            p:icon("wrench")
                            p:anim({ dict = "amb@world_human_welding@male@base", clip = "base", flag = 1 })
                            p:prop({
                                model    = "prop_tool_torch",
                                bone     = 57005,
                                offset   = vector3(0.0, 0.0, 0.0),
                                rot      = vector3(0.0, 0.0, 0.0),
                            })
                            p:confirm(function()
                                vehicle.bodyHealth = 1000
                                LM:notify(function(n)
                                    n:message(vehicle.label .. " repaired!")
                                    n:type("success")
                                end)
                            end)
                            p:cancel(function()
                                LM:notify(function(n)
                                    n:message("Repair cancelled.")
                                    n:type("warning"); n:duration(2500)
                                end)
                            end)
                        end)
                    end)
                    a:cancel("Cancel")
                end)
            end,
        })

        menu:button("Sell", {
            icon         = "badge-dollar-sign",
            confirm_hold = 2000,
            hint         = formatPrice(math.floor((vehicle.price or 50000) / 2)),
            cb = function()
                for i, v in ipairs(playerVehicles) do
                    if v.model == vehicle.model then table.remove(playerVehicles, i) break end
                end
                LM:notify(function(n)
                    n:message(vehicle.label .. " sold!")
                    n:type("success"); n:duration(5000)
                end)
            end,
        })

        menu:back("Back")
    end)
end

-- ── Main garage menu ──────────────────────────────────────────────────────────

local function openGarageMenu()
    LM:context(function(menu)
        menu:title("Los Santos Garage")
        menu:banner("https://i.imgur.com/placeholder.png")
        menu:nav("both")

        -- Tab: My Garage
        menu:tab("My Garage", function(t)
            if #playerVehicles == 0 then
                t:header("No registered vehicle", { align = "center" })
                return
            end

            for _, vehicle in ipairs(playerVehicles) do
                local v = vehicle
                t:button(v.label, {
                    icon   = "car",
                    arrow  = true,
                    badge  = function()
                        return string.format("%d%%", math.floor(v.bodyHealth / 10))
                    end,
                    color  = function() return healthToColor(v.bodyHealth) end,
                    refresh = 1000,
                    preview = {
                        title = v.label,
                        desc  = "Personal vehicle",
                        stats = {
                            { label = "Fuel",  value = v.fuel,        max = 100,  color = "auto" },
                            { label = "Body",  value = v.bodyHealth,  max = 1000, color = healthToColor(v.bodyHealth) },
                        },
                    },
                    cb = function() openVehicleMenu(v) end,
                })
            end
        end, { icon = "car-front" })

        -- Tab: Buy
        menu:tab("Buy", function(t)
            t:header("Available vehicles", { align = "center" })

            for _, car in ipairs(vehiclesForSale) do
                local c = car
                t:button(c.label, {
                    icon  = "shopping-cart",
                    hint  = formatPrice(c.price),
                    arrow = true,
                    preview = {
                        title = c.label,
                        desc  = "New vehicle — immediate delivery",
                        stats = { { label = "Price", value = c.price, max = 1000000 } },
                    },
                    cb = function()
                        LM:alert(function(a)
                            a:title("Buy " .. c.label)
                            a:message(string.format("Confirm purchase of %s for %s?",
                                c.label, formatPrice(c.price)))
                            a:confirm("Buy", function()
                                table.insert(playerVehicles, {
                                    model = c.model, label = c.label,
                                    fuel = 100, bodyHealth = 1000, price = c.price,
                                })
                                LM:notify(function(n)
                                    n:message(c.label .. " purchased! Find it in My Garage.")
                                    n:type("success"); n:duration(5000)
                                end)
                            end)
                            a:cancel("Cancel")
                        end)
                    end,
                })
            end
        end, { icon = "store" })

        -- Tab: Options
        menu:tab("Options", function(t)
            t:toggle("Garage notifications", {
                default = true,
                icon    = "bell",
                cb = function(val)
                    LM:notify(function(n)
                        n:message("Notifications " .. (val and "enabled" or "disabled"))
                        n:type(val and "success" or "info"); n:duration(2000)
                    end)
                end,
            })

            t:slider("Alert distance (m)", {
                min = 50, max = 500, step = 50, default = 150, suffix = " m",
                icon = "radar",
            })
        end, { icon = "settings" })
    end)
end

-- ── Target zone ───────────────────────────────────────────────────────────────

Citizen.CreateThread(function()
    LM:target_add_sphere(garageCoords, 3.0, {
        label   = "Garage",
        icon    = "car-front",
        actions = {
            { label = "Open garage", icon = "door-open", cb = function() openGarageMenu() end },
        },
    })
end)
```
