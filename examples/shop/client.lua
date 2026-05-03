-- Exemple LastMenu : Boutique complète
--
-- Démontre :
--   accordion    — catégories repliables
--   stepper      — quantité
--   list         — variante/couleur de stock
--   color_picker — couleur personnalisée pour vêtements
--   input_inline — code promo dans le menu
--   input_async  — formulaire de livraison
--   alert_async  — confirmation d'achat
--   notify()     — résultat de commande
--   target_add_box() — zone de boutique

local LM = exports.LastMenu

-- ─── Catalogue fictif ────────────────────────────────────────────────────────

local catalog = {
    {
        category = "Alimentation",
        icon     = "utensils",
        items = {
            { label = "Burger",       price = 5,   icon = "beef",       variants = { "Normal", "Double", "Végé" } },
            { label = "Eau minérale", price = 2,   icon = "droplets",   variants = { "50 cl", "1 L" } },
            { label = "Café",         price = 3,   icon = "coffee",     variants = { "Express", "Allongé", "Latte" } },
            { label = "Pizza",        price = 12,  icon = "pizza",      variants = { "Margherita", "Pepperoni", "4 Fromages" } },
        },
    },
    {
        category = "Équipement",
        icon     = "backpack",
        items = {
            { label = "Gilet pare-balles", price = 500,  icon = "shield",      variants = { "Standard", "Lourd", "Militaire" } },
            { label = "Kit médical",       price = 150,  icon = "heart-pulse", variants = { "Petit", "Standard", "Grand" } },
            { label = "Lampe torche",      price = 40,   icon = "flashlight",  variants = { "Compacte", "Longue portée" } },
        },
    },
    {
        category = "Vêtements",
        icon     = "shirt",
        items = {
            { label = "T-shirt", price = 30, icon = "shirt",    useColorPicker = true },
            { label = "Casquette", price = 20, icon = "hat",    useColorPicker = true },
            { label = "Baskets", price = 80,  icon = "footprints", variants = { "Blanc", "Noir", "Rouge", "Bleu" } },
        },
    },
}

-- ─── Panier ──────────────────────────────────────────────────────────────────

local cart = {}     -- { label, price, qty, variant, color }

local function cartTotal()
    local total = 0
    for _, item in ipairs(cart) do total = total + item.price * item.qty end
    return total
end

-- ─── Ouverture de la boutique ─────────────────────────────────────────────────

local function openShop()
    LM:context(function(menu)
        menu:title("SuperShop LS")
        menu:description("Bienvenue dans notre boutique !")
        menu:animation("fade")

        -- Code promo en haut du menu (toujours visible)
        menu:input_inline("Code promo", {
            type        = "text",
            placeholder = "ex: LASTTMENU10",
            icon        = "tag",
            maxlen      = 16,
            cb = function(val)
                if val == "LASTMENU10" then
                    LM:notify(function(n)
                        n:message("Code promo appliqué : -10% !")
                        n:type("success")
                    end)
                elseif val ~= "" then
                    LM:notify(function(n)
                        n:message("Code promo invalide.")
                        n:type("error")
                        n:duration(2500)
                    end)
                end
            end,
        })

        menu:separator()

        -- Accordéons par catégorie
        for _, cat in ipairs(catalog) do
            local c = cat
            menu:accordion(c.category, function(acc)
                for _, item in ipairs(c.items) do
                    local it = item

                    if it.useColorPicker then
                        -- ─ Vêtement avec color picker ─────────────────────
                        local chosenColor = "#e94560"
                        local chosenQty   = 1

                        acc:color_picker(it.label .. " — Couleur", {
                            icon    = it.icon,
                            default = chosenColor,
                            cb = function(hex) chosenColor = hex end,
                        })
                        acc:stepper("Quantité", {
                            min     = 1,
                            max     = 5,
                            step    = 1,
                            default = 1,
                            cb = function(val) chosenQty = val end,
                        })
                        acc:button("Ajouter au panier — " .. it.label, {
                            icon      = "shopping-cart",
                            hint      = string.format("%d $", it.price),
                            keep_open = true,
                            cb = function()
                                table.insert(cart, {
                                    label   = it.label,
                                    price   = it.price,
                                    qty     = chosenQty,
                                    variant = nil,
                                    color   = chosenColor,
                                })
                                LM:notify(function(n)
                                    n:message(it.label .. " ajouté au panier.")
                                    n:type("info")
                                    n:duration(2000)
                                end)
                            end,
                        })

                    elseif it.variants then
                        -- ─ Article avec variantes ──────────────────────────
                        local chosenIdx = 1
                        local chosenQty = 1

                        acc:list(it.label .. " — Variante", {
                            icon    = it.icon,
                            items   = it.variants,
                            default = 1,
                            cb = function(idx) chosenIdx = idx end,
                        })
                        acc:stepper("Quantité", {
                            min     = 1,
                            max     = 10,
                            step    = 1,
                            default = 1,
                            cb = function(val) chosenQty = val end,
                        })
                        acc:button("Ajouter au panier — " .. it.label, {
                            icon      = "shopping-cart",
                            hint      = string.format("%d $", it.price),
                            keep_open = true,
                            cb = function()
                                table.insert(cart, {
                                    label   = it.label,
                                    price   = it.price,
                                    qty     = chosenQty,
                                    variant = it.variants[chosenIdx],
                                    color   = nil,
                                })
                                LM:notify(function(n)
                                    n:message(it.label .. " (" .. it.variants[chosenIdx] .. ") ajouté.")
                                    n:type("info")
                                    n:duration(2000)
                                end)
                            end,
                        })
                    end
                end
            end, { icon = c.icon })
        end

        menu:separator()

        -- Résumé panier + commande
        menu:button("Voir le panier", {
            icon  = "shopping-bag",
            arrow = true,
            badge = function() return #cart > 0 and tostring(#cart) .. " article(s)" or "Vide" end,
            hint  = function() return cartTotal() > 0 and cartTotal() .. " $" or "" end,
            refresh = 500,
            cb = function()
                if #cart == 0 then
                    LM:notify(function(n)
                        n:message("Votre panier est vide.")
                        n:type("warning")
                        n:duration(2500)
                    end)
                    return
                end

                -- Récapitulatif en sous-menu
                LM:context(function(sub)
                    sub:title("Mon Panier")
                    sub:animation("slideRight")

                    for _, cartItem in ipairs(cart) do
                        local ci = cartItem
                        local detail = ci.variant or (ci.color and "Couleur: " .. ci.color) or ""
                        sub:button(ci.label, {
                            icon  = "package",
                            badge = string.format("x%d  %d $", ci.qty, ci.price * ci.qty),
                            hint  = detail,
                        })
                    end

                    sub:separator()
                    sub:stat("Total", {
                        value  = function() return cartTotal() end,
                        max    = 10000,
                        suffix = " $",
                        color  = "#60a5fa",
                        refresh = 300,
                    })

                    sub:button("Commander", {
                        icon         = "check-circle",
                        confirm_hold = 1500,
                        cb = function()
                            -- Demander une adresse de livraison
                            Citizen.CreateThread(function()
                                local values = LM:input_async(function(form)
                                    form:title("Livraison")
                                    form:field("Nom", {
                                        type        = "text",
                                        placeholder = "Votre nom",
                                        maxlen      = 30,
                                    })
                                    form:field("Téléphone", {
                                        type    = "number",
                                        min     = 10000000,
                                        max     = 99999999,
                                        placeholder = "8 chiffres",
                                    })
                                    form:confirm("Valider la commande")
                                    form:cancel("Annuler")
                                end)

                                if not values then return end

                                -- En prod : TriggerServerEvent("shop:order", cart, values)
                                cart = {}
                                LM:notify(function(n)
                                    n:message(string.format(
                                        "Commande confirmée pour %s ! Livraison en cours.",
                                        values[1]
                                    ))
                                    n:type("success")
                                    n:duration(6000)
                                end)
                            end)
                        end,
                    })

                    sub:button("Vider le panier", {
                        icon  = "trash-2",
                        confirm_hold = true,
                        cb = function()
                            cart = {}
                            LM:notify(function(n)
                                n:message("Panier vidé.")
                                n:type("info")
                                n:duration(2000)
                            end)
                        end,
                    })

                    sub:back("Retour à la boutique")
                end)
            end,
        })
    end)
end

-- ─── Zone cible devant la boutique ───────────────────────────────────────────

Citizen.CreateThread(function()
    LM:target_add_box(vector3(-707.0, -905.0, 19.0), {
        width   = 4.0,
        length  = 2.0,
        heading = 0.0,
        label   = "SuperShop",
        icon    = "store",
        actions = {
            {
                label = "Ouvrir la boutique",
                icon  = "shopping-bag",
                cb    = function() openShop() end,
            },
        },
    })
end)

local showCoords = false

RegisterCommand('coords', function()
    showCoords = not showCoords
    
    if showCoords then
        local coords = GetEntityCoords(PlayerPedId())
        local heading = GetEntityHeading(PlayerPedId())
        
        -- Formatage propre pour copier-coller direct dans tes scripts
        local coordsText = string.format("vector3(%.2f, %.2f, %.2f)", coords.x, coords.y, coords.z)
        
        -- Envoie les coords dans le presse-papier (nécessite NUI)
        SendNUIMessage({
            type = 'copy',
            text = coordsText
        })
        
        print("Coordonnées copiées : " .. coordsText)
    end
end, false)

-- Affichage HUD (DrawText)
Citizen.CreateThread(function()
    while true do
        local wait = 500
        if showCoords then
            wait = 0
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local heading = GetEntityHeading(playerPed)

            DrawGenericText(string.format("~r~X~s~: %.2f  ~g~Y~s~: %.2f  ~b~Z~s~: %.2f  ~y~H~s~: %.2f", coords.x, coords.y, coords.z, heading))
        end
        Citizen.Wait(wait)
    end
end)

-- Fonction utilitaire pour dessiner le texte sur l'écran
function DrawGenericText(text)
    SetTextFont(4)
    SetTextScale(0.45, 0.45)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.45, 0.85) -- Position en bas au milieu
end