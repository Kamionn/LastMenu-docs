---
title: Mechanic Job
description: Full mechanic job — radial menu, reusable dashboard handle, diagnostic form, repair/clean progress bars, target on all vehicles with accordion groups.
order: 3
lastUpdated: 2026-04-20
---

Full FiveM resource example. Demonstrates:

- `radial` — main action wheel with sub-radial
- `context_build` — reusable dashboard panel (on/off duty, stats)
- `date_picker` — appointment scheduling
- `input_async` — diagnostic quote form
- `progress` — repair/clean bars with ped animation and prop
- `notify` — grouped result toasts
- `target_add_model` with builder API — accordion groups, toggle, slider, checkbox, submenu

```lua
local LM = exports.LastMenu

-- ── Job state ─────────────────────────────────────────────────────────────────

local isOnDuty   = false
local jobsDone   = 0
local currentVeh = 0

-- ── Reusable dashboard (context_build) ───────────────────────────────────────

local statusPanel = LM:context_build(function(menu)
    menu:title("Mechanic Dashboard")
    menu:animation("fade")

    menu:toggle("On duty", {
        icon    = "hard-hat",
        default = isOnDuty,
        cb = function(val)
            isOnDuty = val
            LM:notify(function(n)
                n:message("You are now " .. (val and "on duty" or "off duty") .. ".")
                n:type(val and "success" or "warning")
                n:group("duty_status")
            end)
        end,
    })

    menu:stat("Jobs done", {
        value   = function() return jobsDone end,
        max     = 50,
        suffix  = " jobs",
        color   = "#60a5fa",
        refresh = 1000,
    })

    menu:separator()

    menu:date_picker("Next appointment", {
        icon    = "calendar",
        format  = "dmy",
        cb = function(iso)
            LM:notify(function(n)
                n:message("Appointment set for " .. iso)
                n:type("info"); n:duration(4000)
            end)
        end,
    })

    menu:separator()

    menu:button("Close", {
        icon = "x-circle",
        cb   = function() statusPanel.close() end,
    })
end)

RegisterCommand("mechanic_panel", function() statusPanel.open() end, false)
RegisterKeyMapping("mechanic_panel", "Mechanic panel", "keyboard", "F5")

-- ── Vehicle repair ────────────────────────────────────────────────────────────

local function repairVehicle(entity)
    LM:progress(function(p)
        p:label("Repairing…")
        p:duration(7000)
        p:cancelable(true)
        p:icon("wrench")
        p:anim({ dict = "amb@world_human_welding@male@base", clip = "base", flag = 1 })
        p:prop({
            model  = "prop_tool_torch",
            bone   = 57005,
            offset = vector3(0.12, 0.0, 0.05),
            rot    = vector3(0.0, 0.0, 0.0),
        })
        p:cb_tick(function(pct)
            if DoesEntityExist(entity) then
                local current = GetVehicleBodyHealth(entity)
                if current < 1000 then
                    SetVehicleBodyHealth(entity, current + (1000 - current) * (pct / 100))
                end
            end
        end)
        p:confirm(function()
            if DoesEntityExist(entity) then
                SetVehicleBodyHealth(entity, 1000.0)
                SetVehicleEngineHealth(entity, 1000.0)
                SetVehicleFixed(entity)
            end
            jobsDone = jobsDone + 1
            LM:notify(function(n)
                n:message("Repair complete! Vehicle as new.")
                n:type("success"); n:duration(5000)
            end)
        end)
        p:cancel(function()
            LM:notify(function(n)
                n:message("Repair interrupted.")
                n:type("warning"); n:duration(3000)
            end)
        end)
    end)
end

-- ── Vehicle clean ─────────────────────────────────────────────────────────────

local function cleanVehicle(entity)
    LM:progress(function(p)
        p:label("Washing…")
        p:duration(4000)
        p:icon("droplets")
        p:anim({ dict = "amb@world_human_car_park_attendant@male@idle_a", clip = "idle_a", flag = 1 })
        p:confirm(function()
            if DoesEntityExist(entity) then
                WashDecalsFromVehicle(entity, 1.0)
                SetVehicleDirtLevel(entity, 0.0)
            end
            LM:notify(function(n)
                n:message("Vehicle cleaned!")
                n:type("success"); n:duration(3000)
            end)
        end)
    end)
end

-- ── Diagnostic & quote ────────────────────────────────────────────────────────

local function openDiagnostic(entity)
    Citizen.CreateThread(function()
        local body   = DoesEntityExist(entity) and GetVehicleBodyHealth(entity)   or 0
        local engine = DoesEntityExist(entity) and GetVehicleEngineHealth(entity) or 0

        local values = LM:input_async(function(form)
            form:title("Diagnostic sheet")
            form:field("Client name",   { type = "text",   placeholder = "e.g. John Doe", maxlen = 40 })
            form:field("Damage notes",  { type = "text",   placeholder = "e.g. Scratched body…",  maxlen = 80 })
            form:field("Estimated cost ($)", {
                type    = "number",
                min     = 0,
                max     = 50000,
                default = math.floor((2000 - body + (1000 - engine)) * 0.5),
            })
            form:confirm_label("Save quote")
            form:cancel_label("Cancel")
        end)

        if not values then return end

        LM:notify(function(n)
            n:message(string.format("Quote saved for %s — %d $", values[1], tonumber(values[3]) or 0))
            n:type("success"); n:duration(6000)
            n:group("devis")
        end)
    end)
end

-- ── Radial menu ───────────────────────────────────────────────────────────────

local function openMechanicRadial(entity)
    currentVeh = entity

    LM:radial(function(r)
        r:center_label("Mechanic")

        r:button("Repair", {
            icon     = "wrench",
            disabled = function() return not isOnDuty end,
            cb       = function() repairVehicle(currentVeh) end,
        })

        r:button("Diagnostic", {
            icon = "clipboard-list",
            cb   = function() openDiagnostic(currentVeh) end,
        })

        r:button("Clean", {
            icon     = "droplets",
            disabled = function() return not isOnDuty end,
            cb       = function() cleanVehicle(currentVeh) end,
        })

        r:button("Advanced", {
            icon    = "settings-2",
            submenu = function(sub)
                sub:center_label("Advanced")

                sub:button("Inflate tyres", {
                    icon = "circle-dot",
                    cb   = function()
                        LM:progress(function(p)
                            p:label("Inflating tyres…")
                            p:duration(3000); p:icon("circle-dot")
                            p:confirm(function()
                                if DoesEntityExist(currentVeh) then
                                    for i = 0, 3 do SetVehicleTyreBurst(currentVeh, i, false, 1000.0) end
                                end
                                LM:notify(function(n) n:message("Tyres inflated!") n:type("success") end)
                            end)
                        end)
                    end,
                })

                sub:button("Charge battery", {
                    icon = "battery-charging",
                    cb   = function()
                        LM:progress(function(p)
                            p:label("Charging battery…")
                            p:duration(5000); p:icon("battery-charging")
                            p:confirm(function()
                                if DoesEntityExist(currentVeh) then
                                    SetVehicleEngineHealth(currentVeh, 1000.0)
                                end
                                LM:notify(function(n) n:message("Battery charged!") n:type("success") end)
                            end)
                        end)
                    end,
                })
            end,
        })
    end)
end

-- ── Target on all vehicles ────────────────────────────────────────────────────

Citizen.CreateThread(function()
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

        t:button("Inspect / Quote", {
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
                cb   = function(entity)
                    LM:progress(function(p)
                        p:label("Inflating tyres…"); p:duration(3000); p:icon("circle-dot")
                        p:confirm(function()
                            if DoesEntityExist(entity) then
                                for i = 0, 3 do SetVehicleTyreBurst(entity, i, false, 1000.0) end
                            end
                            LM:notify(function(n) n:message("Tyres inflated!") n:type("success") end)
                        end)
                    end)
                end,
            })
        end)

        t:group("Options", { icon = "settings-2" }, function(g)
            g:toggle("Lock", {
                icon    = "lock",
                default = false,
                cb      = function(entity, val)
                    if DoesEntityExist(entity) then
                        SetVehicleDoorsLocked(entity, val and 2 or 1)
                    end
                    LM:notify(function(n)
                        n:message("Vehicle " .. (val and "locked" or "unlocked"))
                        n:type(val and "warning" or "success")
                        n:duration(2000); n:group("veh_lock")
                    end)
                end,
            })
            g:slider("Fuel", {
                icon = "fuel", min = 0, max = 100, step = 5, default = 20, suffix = "%",
                cb   = function(entity, val)
                    -- SetVehicleFuelLevel(entity, val * 0.65)
                end,
            })
            g:checkbox("Invoice generated", {
                icon    = "receipt",
                default = false,
                cb      = function(entity, val)
                    if val then
                        LM:notify(function(n)
                            n:message("Invoice generated and sent to client.")
                            n:type("info"); n:duration(3000)
                        end)
                    end
                end,
            })
        end)

        t:submenu("Mechanic menu", {
            icon = "hard-hat",
            cb   = function(entity) openMechanicRadial(entity) end,
        })
    end)
end)
```
