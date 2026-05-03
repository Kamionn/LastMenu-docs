-- examples/async_confirm.lua
-- Pattern: async alert + async input in sequence, all in one coroutine.
--
-- Demonstrates:
--   • UI_AlertAsync — blocking confirmation
--   • UI_InputAsync — blocking form, typed fields
--   • Chained async UI without callbacks
--   • Coroutine requirement

RegisterCommand('transfer', function()
    Citizen.CreateThread(function()
        -- Step 1: Confirm intent
        local proceed = UI_AlertAsync(function(a)
            a:title('Bank Transfer')
            a:message('You are about to initiate a bank transfer.\nContinue?')
            a:confirm_label('Continue')
            a:cancel_label('Abort')
        end)

        if not proceed then return end

        -- Step 2: Collect details
        local values = UI_InputAsync(function(b)
            b:title('Transfer Details')
            b:field('Recipient ID', {
                type        = 'text',
                placeholder = 'e.g. PLAYER-42',
                maxlen      = 20,
            })
            b:field('Amount (€)', {
                type    = 'number',
                min     = 1,
                max     = 50000,
                default = 100,
            })
            b:confirm_label('Send')
            b:cancel_label('Back')
        end)

        if not values then return end  -- user cancelled

        local recipient = values[1]
        local amount    = values[2]   -- already cast to number (opts.type = 'number')

        if not recipient or recipient == '' then
            UI_Notify(function(n)
                n:message('Recipient ID cannot be empty.')
                n:type('error')
                n:duration(4000)
            end)
            return
        end

        -- Step 3: Execute (replace with your server event)
        TriggerServerEvent('bank:transfer', recipient, amount)

        UI_Notify(function(n)
            n:message(string.format('Sent %d€ to %s', amount, recipient))
            n:type('success')
            n:icon('send')
            n:duration(5000)
        end)
    end)
end, false)
