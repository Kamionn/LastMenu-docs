---
title: Input Form
description: Multi-field modal form — text, numbers, passwords input. Built-in NUI-side validation.
order: 3
lastUpdated: 2026-04-14
---

## Opening (callback)

```lua
exports.LastMenu:input(function(form)
    form:title("Create character")
    form:field("First name", { default = "John" })
    form:field("Age", {
        type = "number",
        min  = 18,
        max  = 99,
    })
    form:confirm("Validate", function(values)
        print("First name:", values[1], "Age:", values[2])
    end)
    form:cancel("Cancel")
end)
```

## Blocking opening (coroutine)

Use `input_async` in a `Citizen.CreateThread` to block until confirmation:

```lua
Citizen.CreateThread(function()
    local values = exports.LastMenu:input_async(function(b)
        b:title("Bank transfer")
        b:field("Recipient", { type = "text",   placeholder = "Player name" })
        b:field("Amount",    { type = "number", min = 1, max = 100000 })
        b:field("Reason",    { type = "text",   maxlen = 50 })
    end)

    if not values then return end  -- cancelled

    TriggerServerEvent('bank:transfer', values[1], values[2], values[3])
end)
```

> See [Async API](/docs/avance/async-api) for details on multi-step chaining.

## Reusable form

```lua
local loginForm = exports.LastMenu:input_build(function(form)
    form:title("Login")
    form:field("Username",   { maxlen = 24 })
    form:field("Password",   { type = "password" })
    form:confirm("Login", function(v) login(v[1], v[2]) end)
    form:cancel("Cancel")
end)

-- Resets fields to their `default` value on each call
loginForm.open()
```

---

## Builder methods

| Method | Args | Description |
|---|---|---|
| `form:title(str)` | `string` | Optional header displayed above fields |
| `form:field(label, opts)` | `string, table` | Adds an input field |
| `form:confirm(label, cb)` | `string, function(values)` | Main button — `values` is a 1-indexed array |
| `form:cancel(label, cb?)` | `string, function?` | Secondary button — optional callback |

---

## Field options

| Option | Type | Default | Description |
|---|---|---|---|
| `type` | `string` | `"text"` | `"text"` `"number"` `"password"` `"email"` |
| `default` | `string\|number` | `""` | Pre-filled value |
| `placeholder` | `string` | `nil` | Placeholder text when field is empty |
| `maxlen` | `number` | `nil` | `maxlength` attribute |
| `min` | `number` | `nil` | Minimum value (numeric fields) |
| `max` | `number` | `nil` | Maximum value (numeric fields) |
| `pattern` | `string` | `nil` | JavaScript regex — validated NUI-side on confirmation |
| `pattern_error` | `string` | `"Invalid format"` | Error message shown if pattern doesn't match |

---

## NUI-side validation

Validation runs on confirmation, **before** triggering the callback. If a field fails, an inline error message is displayed and the callback is **not** called.

Built-in validations:
- `type = "number"` — must be a valid number; `min` / `max` are applied
- `pattern` — regex applied via `new RegExp(pattern).test(value)`

```lua
-- License plate AA-123-BB
form:field("Plate", {
    maxlen        = 9,
    pattern       = "^[A-Z]{2}-\\d{3}-[A-Z]{2}$",
    pattern_error = "Expected format: AA-123-BB",
})

-- Valid email
form:field("Email", {
    pattern       = "^[^@]+@[^@]+\\.[^@]+$",
    pattern_error = "Invalid email",
})
```

> **Lua note**: Lua uses `\\` to produce a single `\` in the string sent to JavaScript. The JS regex correctly receives `\d`, `\.`, etc.

---

## Keyboard navigation

| Key | Action |
|---|---|
| `Tab` / `Enter` | Move to next field |
| `Enter` on last field | Triggers confirmation |
| `Escape` | Triggers cancellation (if defined) |

---

## Returned values

Values in the `confirm` callback are **automatically cast** according to field type:
- `type = "number"` → returns a Lua `number` (or raw string if `tonumber()` fails)
- All other types → return `string`

The modal blocks the stack while open. Pressing `Escape` triggers the `cancel` callback if defined.
