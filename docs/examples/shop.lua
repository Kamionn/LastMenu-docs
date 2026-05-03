-- examples/shop.lua
-- A shop menu with reactive stock/funds display, disabled state,
-- and an async confirmation dialog before purchase.
--
-- Demonstrates:
--   • b:stat() with reactive value/max
--   • b:button() with reactive disabled + stable opts.id
--   • UI_AlertAsync for a coroutine-blocking confirmation
--   • UI_Notify for feedback toasts

-- Simulated player state (replace with your actual data source)
local playerFunds  = 1500
local itemStock    = { burger = 5, soda = 12, coffee = 0 }
local itemPrices   = { burger = 200, soda = 50, coffee = 80 }

local shopHandle = UI_Context_Build(function(b)
    b:title('Snack Shop')
    b:banner('nui://lastmenu/assets/shop_banner.png')

    b:stat('Funds', {
        value   = function() return playerFunds end,
        max     = 2000,
        suffix  = '€',
        refresh = 500,
    })

    b:separator()

    for itemName, price in pairs(itemPrices) do
        local stock = itemStock[itemName]
        b:button(itemName:sub(1,1):upper() .. itemName:sub(2) .. ' — ' .. price .. '€', {
            id       = 'buy_' .. itemName,   -- stable ID, not positional
            icon     = 'shopping-cart',
            hint     = function()
                return 'Stock: ' .. (itemStock[itemName] or 0)
            end,
            disabled = function()
                return playerFunds < price or (itemStock[itemName] or 0) == 0
            end,
            refresh  = 500,
            cb = function()
                Citizen.CreateThread(function()
                    local confirmed = UI_AlertAsync(function(a)
                        a:title('Confirm Purchase')
                        a:message('Buy ' .. itemName .. ' for ' .. price .. '€?')
                        a:confirm_label('Buy')
                        a:cancel_label('Cancel')
                    end)

                    if confirmed then
                        playerFunds         = playerFunds - price
                        itemStock[itemName] = (itemStock[itemName] or 0) - 1

                        UI_Notify(function(n)
                            n:message('Purchased ' .. itemName .. '!')
                            n:type('success')
                            n:icon('check')
                            n:duration(3000)
                        end)
                    end
                end)
            end,
        })
    end

    b:separator()
    b:back('Close')
end)

-- Open on key press (example binding)
RegisterCommand('shop', function()
    shopHandle.open()
end, false)
