-- Exemple LastMenu : Système de garage complet
--
-- Démontre :
--   context()        — menu à onglets avec sous-menus et stats réactives
--   alert_async()    — confirmation avant action destructive
--   progress()       — barre de progression avec animation de ped et prop
--   notify()         — toast de résultat
--   target_add_sphere() — zone d'interaction au sol
--
-- DONNÉES FICTIVES — remplacer par votre logique serveur.

local LM = exports.LastMenu

-- ─── Données fictives ────────────────────────────────────────────────────────

local playerVehicles = {
    { model = "adder",    label = "Adder",    fuel = 82, bodyHealth = 1000 },
    { model = "zentorno", label = "Zentorno", fuel = 41, bodyHealth = 740  },
    { model = "t20",      label = "T20",      fuel = 95, bodyHealth = 980  },
}

local vehiclesForSale = {
    { model = "sultan",   label = "Sultan RS",  price = 12000 },
    { model = "elegy2",   label = "Elegy RH8",  price = 95000 },
    { model = "banshee2", label = "Banshee 900R", price = 565000 },
}

local garageCoords = vector3(215.0, -810.0, 30.0)

-- ─── Utilitaires ─────────────────────────────────────────────────────────────

local function healthToColor(hp)
    local pct = hp / 1000
    if pct > 0.75 then return "#4ade80" end
    if pct > 0.40 then return "#facc15" end
    return "#f87171"
end

local function formatPrice(n)
    return string.format("%d $", n)
end

-- ─── Sous-menu d'un véhicule possédé ─────────────────────────────────────────

local function openVehicleMenu(vehicle)
    LM:context(function(menu)
        menu:title(vehicle.label)
        menu:description("Options du véhicule")
        menu:animation("slideRight")

        -- Stat réactive : carburant (simulé ici, en prod lire la vraie valeur)
        menu:stat("Carburant", {
            value  = function() return vehicle.fuel end,
            max    = 100,
            suffix = "%",
            color  = "auto",
            refresh = 1000,
        })

        -- Stat réactive : état de la carrosserie
        menu:stat("Carrosserie", {
            value  = function() return vehicle.bodyHealth end,
            max    = 1000,
            color  = function() return healthToColor(vehicle.bodyHealth) end,
            refresh = 800,
        })

        menu:separator()

        -- Sortir le véhicule
        menu:button("Sortir le véhicule", {
            icon = "car",
            arrow = true,
            cb = function()
                LM:alert(function(a)
                    a:title("Sortir le véhicule")
                    a:message("Faire apparaître le " .. vehicle.label .. " devant le garage ?")
                    a:confirm("Sortir", function()
                        LM:progress(function(p)
                            p:label("Sortie du véhicule…")
                            p:duration(3000)
                            p:icon("car")
                            p:anim({
                                dict  = "anim@heists@ornate_bank@security_guard",
                                clip  = "stand_fire_loop_pistol",
                                flag  = 1,
                            })
                            p:onComplete(function()
                                -- En prod : RequestModel() + CreateVehicle()
                                LM:notify(function(n)
                                    n:message(vehicle.label .. " sorti avec succès !")
                                    n:type("success")
                                    n:duration(4000)
                                end)
                            end)
                        end)
                    end)
                    a:cancel("Annuler")
                end)
            end,
        })

        -- Réparer le véhicule
        menu:button("Réparer", {
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
                    a:title("Réparer le véhicule")
                    a:message(string.format(
                        "Réparer le %s pour %s ?",
                        vehicle.label, formatPrice(cost)
                    ))
                    a:confirm("Payer & Réparer", function()
                        LM:progress(function(p)
                            p:label("Réparation en cours…")
                            p:duration(5000)
                            p:cancel(true)
                            p:icon("wrench")
                            p:anim({
                                dict = "amb@world_human_welding@male@base",
                                clip = "base",
                                flag = 1,
                            })
                            p:prop({
                                model    = "prop_tool_torch",
                                bone     = 57005,
                                offset   = vector3(0.0, 0.0, 0.0),
                                rotation = vector3(0.0, 0.0, 0.0),
                            })
                            p:onComplete(function()
                                vehicle.bodyHealth = 1000
                                LM:notify(function(n)
                                    n:message(vehicle.label .. " réparé !")
                                    n:type("success")
                                end)
                            end)
                            p:onCancel(function()
                                LM:notify(function(n)
                                    n:message("Réparation annulée.")
                                    n:type("warning")
                                    n:duration(2500)
                                end)
                            end)
                        end)
                    end)
                    a:cancel("Annuler")
                end)
            end,
        })

        -- Vendre le véhicule (confirm_hold pour éviter les erreurs)
        menu:button("Vendre", {
            icon         = "badge-dollar-sign",
            confirm_hold = 2000,
            hint         = formatPrice(math.floor(vehicle.price or 50000) / 2),
            cb = function()
                local idx = nil
                for i, v in ipairs(playerVehicles) do
                    if v.model == vehicle.model then idx = i break end
                end
                if idx then table.remove(playerVehicles, idx) end
                LM:notify(function(n)
                    n:message(vehicle.label .. " vendu !")
                    n:type("success")
                    n:duration(5000)
                end)
            end,
        })

        menu:back("Retour")
    end)
end

-- ─── Menu principal du garage ─────────────────────────────────────────────────

local function openGarageMenu()
    LM:context(function(menu)
        menu:title("Garage Los Santos")
        menu:banner("https://i.imgur.com/placeholder.png") -- remplacer par une vraie URL
        menu:nav("both")

        -- ── Onglet : Mon Garage ──────────────────────────────────────────────
        menu:tab("Mon Garage", function(t)
            if #playerVehicles == 0 then
                t:header("Aucun véhicule enregistré", { align = "center" })
                return
            end

            for _, vehicle in ipairs(playerVehicles) do
                local v = vehicle -- capture locale pour les closures réactives
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
                        desc  = "Véhicule personnel",
                        stats = {
                            { label = "Carburant",  value = v.fuel,        max = 100,  color = "auto" },
                            { label = "Carrosserie", value = v.bodyHealth,  max = 1000, color = healthToColor(v.bodyHealth) },
                        },
                    },
                    cb = function() openVehicleMenu(v) end,
                })
            end
        end, { icon = "car-front" })

        -- ── Onglet : Acheter ─────────────────────────────────────────────────
        menu:tab("Acheter", function(t)
            t:header("Véhicules disponibles", { align = "center" })

            for _, car in ipairs(vehiclesForSale) do
                local c = car
                t:button(c.label, {
                    icon  = "shopping-cart",
                    hint  = formatPrice(c.price),
                    arrow = true,
                    preview = {
                        title = c.label,
                        desc  = "Véhicule neuf — livraison immédiate",
                        stats = {
                            { label = "Prix", value = c.price, max = 1000000 },
                        },
                    },
                    cb = function()
                        LM:alert(function(a)
                            a:title("Acheter " .. c.label)
                            a:message(string.format(
                                "Confirmer l'achat du %s pour %s ?",
                                c.label, formatPrice(c.price)
                            ))
                            a:confirm("Acheter", function()
                                -- En prod : TriggerServerEvent("garage:buyVehicle", c.model)
                                table.insert(playerVehicles, {
                                    model       = c.model,
                                    label       = c.label,
                                    fuel        = 100,
                                    bodyHealth  = 1000,
                                    price       = c.price,
                                })
                                LM:notify(function(n)
                                    n:message(c.label .. " acheté ! Retrouvez-le dans Mon Garage.")
                                    n:type("success")
                                    n:duration(5000)
                                end)
                            end)
                            a:cancel("Annuler")
                        end)
                    end,
                })
            end
        end, { icon = "store" })

        -- ── Onglet : Paramètres ──────────────────────────────────────────────
        menu:tab("Options", function(t)
            t:toggle("Notifications garage", {
                default = true,
                icon    = "bell",
                cb = function(val)
                    LM:notify(function(n)
                        n:message("Notifications " .. (val and "activées" or "désactivées"))
                        n:type(val and "success" or "info")
                        n:duration(2000)
                    end)
                end,
            })

            t:slider("Distance d'alerte (m)", {
                min     = 50,
                max     = 500,
                step    = 50,
                default = 150,
                suffix  = " m",
                icon    = "radar",
            })
        end, { icon = "settings" })
    end)
end

-- ─── Zone cible au garage ─────────────────────────────────────────────────────

Citizen.CreateThread(function()
    LM:target_add_sphere(garageCoords, 3.0, {
        label   = "Garage",
        icon    = "car-front",
        actions = {
            {
                label = "Ouvrir le garage",
                icon  = "door-open",
                cb    = function() openGarageMenu() end,
            },
        },
    })
end)
