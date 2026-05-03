-- examples/reactive_status.lua
-- A live HUD-style status menu that updates without close/reopen.
-- Shows player health, armour, hunger and thirst as stat bars.
--
-- Demonstrates:
--   • b:stat() with reactive value
--   • UI_Context_Update to inject new data into an open menu
--   • Handle.update() method
--   • Persistent menu handle pattern

-- Simulated player vitals (replace with your framework's data)
local vitals = { health = 200, armour = 50, hunger = 85, thirst = 60 }

-- Simulate vitals changing over time
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000)
        vitals.hunger  = math.max(0, vitals.hunger  - math.random(1, 3))
        vitals.thirst  = math.max(0, vitals.thirst  - math.random(2, 5))
        vitals.health  = math.max(0, math.min(200, vitals.health + math.random(-5, 5)))
    end
end)

local function buildStatusMenu(b)
    b:title('Player Status')
    b:nav('keyboard')
    b:cancelable(true)

    b:stat('Health', {
        icon    = 'heart',
        value   = function() return vitals.health end,
        max     = 200,
        refresh = 500,
    })

    b:stat('Armour', {
        icon    = 'shield',
        value   = function() return vitals.armour end,
        max     = 100,
        refresh = 500,
    })

    b:separator()

    b:stat('Hunger', {
        icon    = 'utensils',
        value   = function() return vitals.hunger end,
        max     = 100,
        refresh = 500,
    })

    b:stat('Thirst', {
        icon    = 'droplets',
        value   = function() return vitals.thirst end,
        max     = 100,
        refresh = 500,
    })

    b:separator()

    -- Demonstrates handle.update(): clicking "Refresh" rebuilds the menu
    -- from scratch (useful if you add/remove items based on conditions).
    b:button('Refresh', {
        icon     = 'refresh-cw',
        keep_open = true,
        cb = function()
            -- Rebuild the entire menu structure in-place (no flicker).
            -- If only values change, the reactive watchers handle it automatically.
            -- Use update() only when item count or structure changes.
            statusHandle.update()
        end,
    })

    b:back('Close')
end

local statusHandle = UI_Context_Build(buildStatusMenu)

RegisterCommand('status', function()
    statusHandle.open()
end, false)

-- External update example: could be called from a server event handler
-- to add a "wanted" indicator when the player gets a star.
local function addWantedLevel(stars)
    statusHandle.update(function(b)
        buildStatusMenu(b)
        b:header('WANTED', { color = '#ff4444' })
        b:stat('Wanted Level', {
            icon    = 'star',
            value   = stars,
            max     = 5,
            color   = '#ff4444',
        })
    end)
end
