---
title: Shop
description: Complete shop menu — accordion categories, variant selection, color picker, cart, async order form and target zone.
order: 1
lastUpdated: 2026-04-20
---

Full FiveM resource example. Demonstrates:

- `accordion` — collapsible product categories
- `stepper` — quantity selector
- `list` — variant/stock carousel
- `color_picker` — clothing color
- `input_inline` — promo code inside the menu
- `input_async` — delivery form (blocking)
- `alert` — purchase confirmation
- `notify` — order feedback
- `target_add_box` — shop zone

```lua
local LM = exports.LastMenu

-- ── Catalogue ─────────────────────────────────────────────────────────────────

local catalog = {
    {
        category = "Food",
        icon     = "utensils",
        items = {
            { label = "Burger",       price = 5,  icon = "beef",     variants = { "Normal", "Double", "Veggie" } },
            { label = "Water",        price = 2,  icon = "droplets", variants = { "50cl", "1L" } },
            { label = "Coffee",       price = 3,  icon = "coffee",   variants = { "Espresso", "Long", "Latte" } },
            { label = "Pizza",        price = 12, icon = "pizza",    variants = { "Margherita", "Pepperoni", "4 Cheese" } },
        },
    },
    {
        category = "Equipment",
        icon     = "backpack",
        items = {
            { label = "Bulletproof vest", price = 500, icon = "shield",      variants = { "Standard", "Heavy", "Military" } },
            { label = "Medical kit",      price = 150, icon = "heart-pulse", variants = { "Small", "Standard", "Large" } },
            { label = "Flashlight",       price = 40,  icon = "flashlight",  variants = { "Compact", "Long range" } },
        },
    },
    {
        category = "Clothing",
        icon     = "shirt",
        items = {
            { label = "T-shirt",   price = 30, icon = "shirt",     useColorPicker = true },
            { label = "Cap",       price = 20, icon = "hat",       useColorPicker = true },
            { label = "Sneakers",  price = 80, icon = "footprints", variants = { "White", "Black", "Red", "Blue" } },
        },
    },
}

-- ── Cart ──────────────────────────────────────────────────────────────────────

local cart = {}

local function cartTotal()
    local total = 0
    for _, item in ipairs(cart) do total = total + item.price * item.qty end
    return total
end

-- ── Shop menu ─────────────────────────────────────────────────────────────────

local function openShop()
    LM:context(function(menu)
        menu:title("SuperShop LS")
        menu:description("Welcome to our shop!")
        menu:animation("fade")

        menu:input_inline("Promo code", {
            type        = "text",
            placeholder = "e.g. LASTMENU10",
            icon        = "tag",
            maxlen      = 16,
            cb = function(val)
                if val == "LASTMENU10" then
                    LM:notify(function(n)
                        n:message("Promo code applied: -10%!")
                        n:type("success")
                    end)
                elseif val ~= "" then
                    LM:notify(function(n)
                        n:message("Invalid promo code.")
                        n:type("error")
                        n:duration(2500)
                    end)
                end
            end,
        })

        menu:separator()

        for _, cat in ipairs(catalog) do
            local c = cat
            menu:accordion(c.category, function(acc)
                for _, item in ipairs(c.items) do
                    local it = item

                    if it.useColorPicker then
                        local chosenColor = "#e94560"
                        local chosenQty   = 1

                        acc:color_picker(it.label .. " — Color", {
                            icon    = it.icon,
                            default = chosenColor,
                            cb = function(hex) chosenColor = hex end,
                        })
                        acc:stepper("Quantity", {
                            min = 1, max = 5, step = 1, default = 1,
                            cb  = function(val) chosenQty = val end,
                        })
                        acc:button("Add to cart — " .. it.label, {
                            icon      = "shopping-cart",
                            hint      = string.format("%d $", it.price),
                            keep_open = true,
                            cb = function()
                                table.insert(cart, { label = it.label, price = it.price,
                                    qty = chosenQty, color = chosenColor })
                                LM:notify(function(n)
                                    n:message(it.label .. " added to cart.")
                                    n:type("info"); n:duration(2000)
                                end)
                            end,
                        })

                    elseif it.variants then
                        local chosenIdx = 1
                        local chosenQty = 1

                        acc:list(it.label .. " — Variant", {
                            icon    = it.icon,
                            items   = it.variants,
                            default = 1,
                            cb = function(idx) chosenIdx = idx end,
                        })
                        acc:stepper("Quantity", {
                            min = 1, max = 10, step = 1, default = 1,
                            cb  = function(val) chosenQty = val end,
                        })
                        acc:button("Add to cart — " .. it.label, {
                            icon      = "shopping-cart",
                            hint      = string.format("%d $", it.price),
                            keep_open = true,
                            cb = function()
                                table.insert(cart, { label = it.label, price = it.price,
                                    qty = chosenQty, variant = it.variants[chosenIdx] })
                                LM:notify(function(n)
                                    n:message(it.label .. " (" .. it.variants[chosenIdx] .. ") added.")
                                    n:type("info"); n:duration(2000)
                                end)
                            end,
                        })
                    end
                end
            end, { icon = c.icon })
        end

        menu:separator()

        menu:button("View cart", {
            icon  = "shopping-bag",
            arrow = true,
            badge = function() return #cart > 0 and tostring(#cart) .. " item(s)" or "Empty" end,
            hint  = function() return cartTotal() > 0 and cartTotal() .. " $" or "" end,
            refresh = 500,
            cb = function()
                if #cart == 0 then
                    LM:notify(function(n)
                        n:message("Your cart is empty.")
                        n:type("warning"); n:duration(2500)
                    end)
                    return
                end

                LM:context(function(sub)
                    sub:title("My Cart")
                    sub:animation("slideRight")

                    for _, ci in ipairs(cart) do
                        local detail = ci.variant or (ci.color and "Color: " .. ci.color) or ""
                        sub:button(ci.label, {
                            icon  = "package",
                            badge = string.format("x%d  %d $", ci.qty, ci.price * ci.qty),
                            hint  = detail,
                        })
                    end

                    sub:separator()
                    sub:stat("Total", {
                        value   = function() return cartTotal() end,
                        max     = 10000,
                        suffix  = " $",
                        color   = "#60a5fa",
                        refresh = 300,
                    })

                    sub:button("Order", {
                        icon         = "check-circle",
                        confirm_hold = 1500,
                        cb = function()
                            Citizen.CreateThread(function()
                                local values = LM:input_async(function(form)
                                    form:title("Delivery")
                                    form:field("Name", { type = "text", placeholder = "Your name", maxlen = 30 })
                                    form:field("Phone", { type = "number", min = 10000000, max = 99999999 })
                                    form:confirm_label("Confirm order")
                                    form:cancel_label("Cancel")
                                end)
                                if not values then return end
                                -- In production: TriggerServerEvent("shop:order", cart, values)
                                cart = {}
                                LM:notify(function(n)
                                    n:message(string.format("Order confirmed for %s! Delivery in progress.", values[1]))
                                    n:type("success"); n:duration(6000)
                                end)
                            end)
                        end,
                    })

                    sub:button("Clear cart", {
                        icon         = "trash-2",
                        confirm_hold = true,
                        cb = function()
                            cart = {}
                            LM:notify(function(n)
                                n:message("Cart cleared.")
                                n:type("info"); n:duration(2000)
                            end)
                        end,
                    })

                    sub:back("Back to shop")
                end)
            end,
        })
    end)
end

-- ── Target zone in front of the shop ─────────────────────────────────────────

Citizen.CreateThread(function()
    LM:target_add_box(vector3(-707.0, -905.0, 19.0), {
        width   = 4.0,
        length  = 2.0,
        heading = 0.0,
        label   = "SuperShop",
        icon    = "store",
        actions = {
            { label = "Open shop", icon = "shopping-bag", cb = function() openShop() end },
        },
    })
end)
```
