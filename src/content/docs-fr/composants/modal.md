---
title: Modal / Alert
description: Boîte de dialogue de confirmation bloquante — deux boutons (confirmer / annuler), callback ou style async.
order: 4
lastUpdated: 2026-04-14
---

## Ouverture (callback)

```lua
exports.LastMenu:alert(function(a)
    a:title("Confirmer l'achat")
    a:message("Acheter cet objet pour 500 € ?")
    a:confirm("Oui, acheter", function()
        -- confirmé
    end)
    a:cancel("Annuler", function()
        -- annulé (optionnel)
    end)
end)
```

## Ouverture bloquante (coroutine)

`alert_async` bloque la coroutine courante et retourne `true` (confirmé) ou `false` (annulé / Escape) :

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

## Alerte réutilisable

```lua
local confirmDialog = exports.LastMenu:alert_build(function(a)
    a:title("Supprimer le personnage")
    a:message("Cette action est irréversible.")
    a:confirm("Supprimer", function() deleteCharacter() end)
    a:cancel("Annuler")
end)

-- Plus tard :
confirmDialog.open()
```

---

## Méthodes du builder

| Méthode | Args | Description |
|---|---|---|
| `a:title(str)` | `string` | En-tête du dialogue |
| `a:message(str)` | `string` | Corps du texte |
| `a:confirm(label, cb)` | `string, function` | Bouton principal (coloré accent) |
| `a:cancel(label, cb)` | `string, function?` | Bouton secondaire (callback optionnel) |
| `b:confirm_label(str)` | `string` | *(mode async)* Label du bouton de confirmation |
| `b:cancel_label(str)` | `string` | *(mode async)* Label du bouton d'annulation |

Les deux boutons ferment automatiquement le modal après avoir déclenché le callback.

---

## Comportement

- Le modal **bloque la stack** — aucun autre menu ne peut s'ouvrir pendant qu'il est visible.
- Appuyer sur **Escape** équivaut à cliquer sur le bouton Annuler.
- Le `cb` de `cancel` est optionnel. L'omettre ferme simplement le dialogue.
- L'alignement (centré / haut-centre / bas-centre) est un paramètre utilisateur (F12).

---

## Exemple de chaînage

Chaîner une confirmation après un formulaire :

```lua
Citizen.CreateThread(function()
    -- Étape 1 : formulaire
    local values = exports.LastMenu:input_async(function(b)
        b:title("Créer un personnage")
        b:field("Prénom", { type = "text", maxlen = 20 })
        b:field("Nom",    { type = "text", maxlen = 20 })
    end)
    if not values then return end

    -- Étape 2 : confirmation
    local ok = exports.LastMenu:alert_async(function(b)
        b:title("Confirmer la création")
        b:message(string.format("Créer le personnage %s %s ?", values[1], values[2]))
        b:confirm_label("Créer")
        b:cancel_label("Retour")
    end)
    if not ok then return end

    TriggerServerEvent('character:create', values[1], values[2])
end)
```
