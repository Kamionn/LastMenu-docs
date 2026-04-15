---
title: Input Form
description: Formulaire modal multi-champs — saisie de texte, nombres, mots de passe. Validation intégrée côté NUI.
order: 3
lastUpdated: 2026-04-14
---

## Ouverture (callback)

```lua
exports.LastMenu:input(function(form)
    form:title("Créer un personnage")
    form:field("Prénom", { default = "Jean" })
    form:field("Âge", {
        type = "number",
        min  = 18,
        max  = 99,
    })
    form:confirm("Valider", function(values)
        print("Prénom :", values[1], "Âge :", values[2])
    end)
    form:cancel("Annuler")
end)
```

## Ouverture bloquante (coroutine)

Utilise `input_async` dans un `Citizen.CreateThread` pour bloquer jusqu'à la confirmation :

```lua
Citizen.CreateThread(function()
    local values = exports.LastMenu:input_async(function(b)
        b:title("Virement bancaire")
        b:field("Destinataire", { type = "text",   placeholder = "Nom du joueur" })
        b:field("Montant",      { type = "number", min = 1, max = 100000 })
        b:field("Motif",        { type = "text",   maxlen = 50 })
    end)

    if not values then return end  -- annulé

    TriggerServerEvent('bank:transfer', values[1], values[2], values[3])
end)
```

> Voir [API Async](/docs/avance/async-api) pour les détails sur le chaînage multi-étapes.

## Formulaire réutilisable

```lua
local loginForm = exports.LastMenu:input_build(function(form)
    form:title("Connexion")
    form:field("Identifiant",   { maxlen = 24 })
    form:field("Mot de passe",  { type = "password" })
    form:confirm("Se connecter", function(v) login(v[1], v[2]) end)
    form:cancel("Annuler")
end)

-- Réinitialise les champs à leur valeur `default` à chaque appel
loginForm.open()
```

---

## Méthodes du builder

| Méthode | Args | Description |
|---|---|---|
| `form:title(str)` | `string` | En-tête optionnel affiché au-dessus des champs |
| `form:field(label, opts)` | `string, table` | Ajoute un champ de saisie |
| `form:confirm(label, cb)` | `string, function(values)` | Bouton principal — `values` est un tableau indexé à partir de 1 |
| `form:cancel(label, cb?)` | `string, function?` | Bouton secondaire — callback optionnel |

---

## Options des champs

| Option | Type | Défaut | Description |
|---|---|---|---|
| `type` | `string` | `"text"` | `"text"` `"number"` `"password"` `"email"` |
| `default` | `string\|number` | `""` | Valeur pré-remplie |
| `placeholder` | `string` | `nil` | Texte fantôme quand le champ est vide |
| `maxlen` | `number` | `nil` | Attribut `maxlength` |
| `min` | `number` | `nil` | Valeur minimale (champs numériques) |
| `max` | `number` | `nil` | Valeur maximale (champs numériques) |
| `pattern` | `string` | `nil` | Regex JavaScript — validée côté NUI à la confirmation |
| `pattern_error` | `string` | `"Format invalide"` | Message d'erreur affiché si le pattern ne correspond pas |

---

## Validation côté NUI

La validation s'exécute à la confirmation, **avant** de déclencher le callback. Si un champ échoue, un message d'erreur inline est affiché et le callback n'est **pas** appelé.

Validations intégrées :
- `type = "number"` — doit être un nombre valide ; `min` / `max` sont appliqués
- `pattern` — regex appliquée via `new RegExp(pattern).test(value)`

```lua
-- Plaque d'immatriculation AA-123-BB
form:field("Plaque", {
    maxlen        = 9,
    pattern       = "^[A-Z]{2}-\\d{3}-[A-Z]{2}$",
    pattern_error = "Format attendu : AA-123-BB",
})

-- Email valide
form:field("Email", {
    pattern       = "^[^@]+@[^@]+\\.[^@]+$",
    pattern_error = "Email invalide",
})
```

> **Note Lua** : Lua utilise `\\` pour produire un seul `\` dans la chaîne envoyée à JavaScript. Le regex JS reçoit correctement `\d`, `\.`, etc.

---

## Navigation clavier

| Touche | Action |
|---|---|
| `Tab` / `Entrée` | Passer au champ suivant |
| `Entrée` sur le dernier champ | Déclenche la confirmation |
| `Escape` | Déclenche l'annulation (si définie) |

---

## Valeurs retournées

Les valeurs dans le callback `confirm` sont **castées automatiquement** selon le type du champ :
- `type = "number"` → retourne un `number` Lua (ou la chaîne brute si `tonumber()` échoue)
- Tous les autres types → retournent des `string`

Le modal bloque la stack pendant son ouverture. Appuyer sur `Escape` déclenche le callback `cancel` s'il est défini.
