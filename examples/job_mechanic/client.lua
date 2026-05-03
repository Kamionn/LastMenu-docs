-- Exemple LastMenu : Job mécanicien
--
-- Démontre :
--   radial()           — menu circulaire principal + sous-menu
--   input_async()      — formulaire de devis
--   progress()         — réparation avec animation + prop
--   notify()           — résultats avec grouping
--   target_add_model() — cibler des véhicules (builder API)
--                        banner, accordion, toggle, slider, checkbox,
--                        separator, gradient, confirm_hold, cooldown, submenu
--   context_build()    — handle réutilisable pour le panneau d'état du job
--   date_picker        — date de rendez-vous

local LM = exports.LastMenu

-- ─── État du job ─────────────────────────────────────────────────────────────

local isOnDuty   = false
local jobsDone   = 0
local currentVeh = 0

-- ─── Panneau d'état (handle réutilisable) ────────────────────────────────────
-- Ouvert/fermé via F5 ; se met à jour en temps réel sans se refermer.

local statusPanel = LM:context_build(function(menu)
    menu:title("Tableau de bord mécanicien")
    menu:animation("fade")
    menu:cancelable(true)

    menu:toggle("En service", {
        icon    = "hard-hat",
        default = isOnDuty,
        cb = function(val)
            isOnDuty = val
            LM:notify(function(n)
                n:message("Vous êtes maintenant " .. (val and "en service" or "hors service") .. ".")
                n:type(val and "success" or "warning")
                n:group("duty_status")
            end)
        end,
    })

    menu:stat("Jobs effectués", {
        value   = function() return jobsDone end,
        max     = 50,
        suffix  = " jobs",
        color   = "#60a5fa",
        refresh = 1000,
    })

    menu:separator()

    menu:date_picker("Prochain rendez-vous", {
        icon    = "calendar",
        format  = "dmy",
        default = "",
        cb = function(iso)
            LM:notify(function(n)
                n:message("Rendez-vous enregistré pour le " .. iso)
                n:type("info")
                n:duration(4000)
            end)
        end,
    })

    menu:separator()

    menu:button("Fermer", {
        icon = "x-circle",
        cb   = function() statusPanel.close() end,
    })
end)

RegisterCommand("mechanic_panel", function()
    statusPanel.open()
end, false)
RegisterKeyMapping("mechanic_panel", "Panneau mécanicien", "keyboard", "F5")

-- ─── Réparation d'un véhicule ────────────────────────────────────────────────

local function repairVehicle(entity)
    LM:progress(function(p)
        p:label("Réparation en cours…")
        p:duration(7000)
        p:cancel(true)
        p:icon("wrench")
        p:anim({
            dict  = "amb@world_human_welding@male@base",
            clip  = "base",
            flag  = 1,
        })
        p:prop({
            model    = "prop_tool_torch",
            bone     = 57005,
            offset   = vector3(0.12, 0.0, 0.05),
            rotation = vector3(0.0, 0.0, 0.0),
        })
        p:cb_tick(function(pct)
            if DoesEntityExist(entity) then
                local current = GetVehicleBodyHealth(entity)
                if current < 1000 then
                    SetVehicleBodyHealth(entity, current + (1000 - current) * (pct / 100))
                end
            end
        end)
        p:onComplete(function()
            if DoesEntityExist(entity) then
                SetVehicleBodyHealth(entity, 1000.0)
                SetVehicleEngineHealth(entity, 1000.0)
                SetVehicleFixed(entity)
            end
            jobsDone = jobsDone + 1
            LM:notify(function(n)
                n:message("Réparation terminée ! Véhicule remis à neuf.")
                n:type("success")
                n:duration(5000)
            end)
        end)
        p:onCancel(function()
            LM:notify(function(n)
                n:message("Réparation interrompue.")
                n:type("warning")
                n:duration(3000)
            end)
        end)
    end)
end

-- ─── Diagnostic & devis ──────────────────────────────────────────────────────

local function openDiagnostic(entity)
    Citizen.CreateThread(function()
        local body   = DoesEntityExist(entity) and GetVehicleBodyHealth(entity)   or 0
        local engine = DoesEntityExist(entity) and GetVehicleEngineHealth(entity) or 0

        local values = LM:input_async(function(form)
            form:title("Fiche de diagnostic")
            form:field("Nom du client", {
                type        = "text",
                placeholder = "ex: John Doe",
                maxlen      = 40,
            })
            form:field("Description des dégâts", {
                type        = "text",
                placeholder = "ex: Moteur endommagé, carrosserie rayée…",
                maxlen      = 80,
            })
            form:field("Coût estimé ($)", {
                type    = "number",
                min     = 0,
                max     = 50000,
                default = math.floor((2000 - body + (1000 - engine)) * 0.5),
            })
            form:confirm("Enregistrer le devis")
            form:cancel("Annuler")
        end)

        if not values then return end

        LM:notify(function(n)
            n:message(string.format("Devis enregistré pour %s — %d $", values[1], tonumber(values[3]) or 0))
            n:type("success")
            n:duration(6000)
            n:group("devis")
        end)
    end)
end

-- ─── Nettoyage ───────────────────────────────────────────────────────────────

local function cleanVehicle(entity)
    LM:progress(function(p)
        p:label("Lavage en cours…")
        p:duration(4000)
        p:icon("droplets")
        p:anim({
            dict  = "amb@world_human_car_park_attendant@male@idle_a",
            clip  = "idle_a",
            flag  = 1,
        })
        p:onComplete(function()
            if DoesEntityExist(entity) then
                WashDecalsFromVehicle(entity, 1.0)
                SetVehicleDirtLevel(entity, 0.0)
            end
            LM:notify(function(n)
                n:message("Véhicule nettoyé !")
                n:type("success")
                n:duration(3000)
            end)
        end)
    end)
end

-- ─── Inspection rapide (context menu) ────────────────────────────────────────

local function openInspection(entity)
    if not DoesEntityExist(entity) then return end
    local body   = math.floor(GetVehicleBodyHealth(entity))
    local engine = math.floor(GetVehicleEngineHealth(entity))
    LM:context(function(menu)
        menu:title("Inspection")
        menu:animation("scale")
        menu:stat("Carrosserie", { value = body,   max = 1000, color = "auto" })
        menu:stat("Moteur",      { value = engine, max = 1000, color = "auto" })
        menu:back("Retour")
    end)
end

-- ─── Menu radial principal ───────────────────────────────────────────────────

local function openMechanicRadial(entity)
    currentVeh = entity

    LM:radial(function(r)
        r:center_label("Mécanicien")

        r:button("Réparer", {
            icon     = "wrench",
            disabled = function() return not isOnDuty end,
            cb       = function() repairVehicle(currentVeh) end,
        })

        r:button("Diagnostic", {
            icon = "clipboard-list",
            cb   = function() openDiagnostic(currentVeh) end,
        })

        r:button("Nettoyer", {
            icon     = "droplets",
            disabled = function() return not isOnDuty end,
            cb       = function() cleanVehicle(currentVeh) end,
        })

        r:button("Avancé", {
            icon    = "settings-2",
            submenu = function(sub)
                sub:center_label("Options avancées")

                sub:button("Gonflage pneus", {
                    icon = "circle-dot",
                    cb   = function()
                        LM:progress(function(p)
                            p:label("Gonflage des pneus…")
                            p:duration(3000)
                            p:icon("circle-dot")
                            p:onComplete(function()
                                if DoesEntityExist(currentVeh) then
                                    for i = 0, 3 do
                                        SetVehicleTyreBurst(currentVeh, i, false, 1000.0)
                                    end
                                end
                                LM:notify(function(n)
                                    n:message("Pneus gonflés !")
                                    n:type("success")
                                    n:duration(3000)
                                end)
                            end)
                        end)
                    end,
                })

                sub:button("Recharge batterie", {
                    icon = "battery-charging",
                    cb   = function()
                        LM:progress(function(p)
                            p:label("Recharge batterie…")
                            p:duration(5000)
                            p:icon("battery-charging")
                            p:onComplete(function()
                                if DoesEntityExist(currentVeh) then
                                    SetVehicleEngineHealth(currentVeh, 1000.0)
                                end
                                LM:notify(function(n)
                                    n:message("Batterie rechargée !")
                                    n:type("success")
                                end)
                            end)
                        end)
                    end,
                })

                sub:button("Inspecter", {
                    icon = "search",
                    cb   = function() openInspection(currentVeh) end,
                })
            end,
        })
    end)
end

-- ─── Cible sur les véhicules ─────────────────────────────────────────────────

Citizen.CreateThread(function()
    LM:target_add_model(nil, function(t)
        t:label("Véhicule")
        t:icon("car")
        t:distance(4.0)
        -- t:banner("nui://job_mechanic/img/vehicle_banner.gif")

        -- ── Actions racine ────────────────────────────────────────────────────

        -- Réparation : gradient + maintien 2 s + cooldown 60 s, visible qu'en service
        t:button("Réparer", {
            icon         = "wrench",
            gradient     = true,
            confirm_hold = 2000,
            cooldown     = 60000,
            condition    = function() return isOnDuty end,
            cb           = function(entity) repairVehicle(entity) end,
        })

        -- Diagnostic toujours disponible
        t:button("Inspecter / Devis", {
            icon = "clipboard-list",
            cb   = function(entity) openDiagnostic(entity) end,
        })

        t:separator()

        -- ── Groupe "Services" (accordion) ─────────────────────────────────────

        t:group("Services", { icon = "tool" }, function(g)
            g:button("Nettoyer", {
                icon      = "droplets",
                condition = function() return isOnDuty end,
                cb        = function(entity) cleanVehicle(entity) end,
            })
            g:button("Gonflage pneus", {
                icon = "circle-dot",
                cb   = function(entity)
                    LM:progress(function(p)
                        p:label("Gonflage des pneus…")
                        p:duration(3000)
                        p:icon("circle-dot")
                        p:onComplete(function()
                            if DoesEntityExist(entity) then
                                for i = 0, 3 do SetVehicleTyreBurst(entity, i, false, 1000.0) end
                            end
                            LM:notify(function(n)
                                n:message("Pneus gonflés !")
                                n:type("success")
                                n:duration(3000)
                            end)
                        end)
                    end)
                end,
            })
            g:button("Recharge batterie", {
                icon = "battery-charging",
                cb   = function(entity)
                    LM:progress(function(p)
                        p:label("Recharge batterie…")
                        p:duration(5000)
                        p:icon("battery-charging")
                        p:onComplete(function()
                            if DoesEntityExist(entity) then
                                SetVehicleEngineHealth(entity, 1000.0)
                            end
                            LM:notify(function(n)
                                n:message("Batterie rechargée !")
                                n:type("success")
                            end)
                        end)
                    end)
                end,
            })
        end)

        -- ── Groupe "Options" (accordion) ──────────────────────────────────────

        t:group("Options", { icon = "settings-2" }, function(g)
            -- Toggle : verrouillage du véhicule
            g:toggle("Verrouiller", {
                icon    = "lock",
                default = false,
                cb      = function(entity, val)
                    if DoesEntityExist(entity) then
                        SetVehicleDoorsLocked(entity, val and 2 or 1)
                    end
                    LM:notify(function(n)
                        n:message("Véhicule " .. (val and "verrouillé" or "déverrouillé"))
                        n:type(val and "warning" or "success")
                        n:duration(2000)
                        n:group("veh_lock")
                    end)
                end,
            })
            -- Slider : niveau de carburant
            g:slider("Carburant", {
                icon    = "fuel",
                min     = 0,
                max     = 100,
                step    = 5,
                default = 20,
                suffix  = "%",
                cb      = function(entity, val)
                    -- SetVehicleFuelLevel(entity, val * 0.65)
                end,
            })
            -- Checkbox : marquer une facture comme générée
            g:checkbox("Facture générée", {
                icon    = "receipt",
                default = false,
                cb      = function(entity, val)
                    if val then
                        LM:notify(function(n)
                            n:message("Facture générée et envoyée au client.")
                            n:type("info")
                            n:duration(3000)
                        end)
                    end
                end,
            })
        end)

        t:separator()

        -- ── Sous-menu (ouvre le radial mécanicien complet) ────────────────────

        t:submenu("Menu mécanicien", {
            icon = "hard-hat",
            cb   = function(entity) openMechanicRadial(entity) end,
        })
    end)
end)
