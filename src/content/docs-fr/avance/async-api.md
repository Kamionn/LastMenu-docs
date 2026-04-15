---
title: API Async (coroutine-style)
description: input_async et alert_async — bloquent la coroutine courante comme lib.inputDialog d'ox_lib. Indispensables pour les flux multi-étapes.
order: 2
lastUpdated: 2026-04-14
---

## Principe

`input_async` et `alert_async` appellent `coroutine.yield()` en interne. Ils **bloquent la coroutine courante** jusqu'à ce que le joueur confirme ou annule.

> **Contrainte absolue** : ces fonctions doivent être appelées depuis un `Citizen.CreateThread`. Depuis un `RegisterCommand` ou un `AddEventHandler` sans thread, elles retournent immédiatement `nil`/`false` et aucune UI n'est affichée.

```lua
-- MAUVAIS : AddEventHandler sans coroutine
AddEventHandler('monEvenement', function()
    local ok = exports.LastMenu:alert_async(...)  -- retourne false, rien ne s'affiche
end)

-- CORRECT : wrappé dans un thread
AddEventHandler('monEvenement', function()
    Citizen.CreateThread(function()
        local ok = exports.LastMenu:alert_async(...)
        if ok then ... end
    end)
end)
```

---

## input_async

Ouvre un formulaire multi-champs et bloque jusqu'à confirmation ou annulation.

**Retourne** : `table` (valeurs 1-indexed) si confirmé, `nil` si annulé.

```lua
Citizen.CreateThread(function()
    local values = exports.LastMenu:input_async(function(b)
        b:title("Transfert bancaire")
        b:confirm_label("Envoyer")
        b:cancel_label("Annuler")
        b:field("Destinataire", { type = "text",   placeholder = "Nom du joueur" })
        b:field("Montant",      { type = "number", min = 1, max = 100000 })
        b:field("Motif",        { type = "text",   maxlen = 50 })
    end)

    if not values then
        print("Transfert annulé.")
        return
    end

    -- values[2] est déjà casté en number
    TriggerServerEvent('bank:transfer', values[1], values[2], values[3])
end)
```

---

## alert_async

Ouvre une boîte de confirmation et bloque jusqu'à la réponse du joueur.

**Retourne** : `true` si confirmé, `false` si annulé / Escape.

```lua
Citizen.CreateThread(function()
    local confirmed = exports.LastMenu:alert_async(function(b)
        b:title("Réinitialiser le compte ?")
        b:message("Toute la progression sera perdue. Cette action est irréversible.")
        b:confirm_label("Réinitialiser")
        b:cancel_label("Annuler")
    end)

    if confirmed then
        TriggerServerEvent('account:reset')
    end
end)
```

---

## Chaînage multi-étapes

L'intérêt principal de l'API async est le **chaînage** — une séquence de formulaires et confirmations lisible comme un flux linéaire, sans callbacks imbriqués :

```lua
Citizen.CreateThread(function()
    -- Étape 1 : saisie du personnage
    local values = exports.LastMenu:input_async(function(b)
        b:title("Créer un personnage")
        b:field("Prénom", { type = "text", maxlen = 20 })
        b:field("Nom",    { type = "text", maxlen = 20 })
        b:field("Âge",    { type = "number", min = 18, max = 80 })
    end)
    if not values then return end

    -- Étape 2 : confirmation
    local ok = exports.LastMenu:alert_async(function(b)
        b:title("Confirmer la création")
        b:message(string.format(
            "Créer le personnage %s %s (%s ans) ?",
            values[1], values[2], values[3]
        ))
        b:confirm_label("Créer")
        b:cancel_label("Retour")
    end)
    if not ok then return end

    -- Étape 3 : action serveur
    TriggerServerEvent('character:create', values[1], values[2], values[3])

    exports.LastMenu:notify(function(n)
        n:message("Personnage créé avec succès !")
        n:type("success")
    end)
end)
```

---

## Référence rapide

| Fonction | Retour si confirmé | Retour si annulé |
|---|---|---|
| `input_async(fn)` | `table` (valeurs 1-indexed) | `nil` |
| `alert_async(fn)` | `true` | `false` |

---

## Différence avec le style callback

| Critère | Style callback `input(fn)` | Style async `input_async(fn)` |
|---|---|---|
| Nécessite un thread | Non | Oui (`Citizen.CreateThread`) |
| Lisibilité du flux | Callbacks imbriqués | Linéaire (comme un script synchrone) |
| Chaînage multi-étapes | Possible mais complexe | Naturel |
| Retour de valeur | Via le callback | Via `local values = ...` |
