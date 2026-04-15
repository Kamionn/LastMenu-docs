---
title: Notifications
description: Toasts non-bloquants empilables — success, error, warning, info. Déduplication par groupe, persistance et callbacks de fermeture.
order: 5
lastUpdated: 2026-04-14
---

## Usage de base

```lua
exports.LastMenu:notify(function(n)
    n:message("Action réussie !")
    n:type("success")
    n:duration(3000)
end)
```

### Pattern raccourci

Encapsule les notifications dans une fonction helper pour réduire le boilerplate :

```lua
local UI = exports['LastMenu']

local function notify(msg, t, dur)
    UI:notify(function(n)
        n:message(msg)
        n:type(t or 'success')
        n:duration(dur or 2500)
    end)
end

-- Utilisation
notify("Véhicule réparé !")
notify("Argent insuffisant",        "error")
notify("Attention : zone dangereuse", "warning", 5000)
notify("3 joueurs à proximité",     "info",    4000)
```

---

## Méthodes du builder

| Méthode | Type | Défaut | Description |
|---|---|---|---|
| `n:message(str)` | `string` | `""` | Texte du toast |
| `n:type(str)` | `string` | `"info"` | Style visuel : `"success"` `"error"` `"warning"` `"info"` |
| `n:duration(ms)` | `number` | `3000` | Délai d'auto-fermeture |
| `n:icon(str)` | `string` | *(icône du type)* | Icône Lucide custom — remplace l'icône du type |
| `n:group(key)` | `string` | `nil` | Clé de déduplication — **remplace** le toast existant avec la même clé |
| `n:persistent()` | — | — | Le toast ne se ferme jamais automatiquement — bouton × requis |
| `n:on_dismiss(cb)` | `function` | `nil` | Appelé quand l'utilisateur clique × (pas à l'expiration auto) |

---

## Déduplication par groupe

`n:group(key)` garantit qu'un seul toast par sujet sémantique est visible à la fois. Quand un nouveau toast avec la même clé arrive, le précédent est immédiatement remplacé :

```lua
-- Seul le dernier toast de zone est visible
UI:notify(function(n)
    n:message("Vous entrez dans la Zone Rouge")
    n:type("warning")
    n:group("zone_status")
end)

-- Quelques secondes plus tard...
UI:notify(function(n)
    n:message("Vous quittez la Zone Rouge")
    n:type("info")
    n:group("zone_status")  -- remplace le précédent
end)
```

---

## Icône personnalisée

```lua
UI:notify(function(n)
    n:message("Nouvelle mission disponible")
    n:type("info")
    n:icon("map-pin")   -- n'importe quel nom d'icône Lucide
end)
```

---

## Toast persistant

Utile pour les messages d'état critiques que le joueur doit accuser réception :

```lua
UI:notify(function(n)
    n:message("Serveur en maintenance — reconnexion dans 60s")
    n:type("warning")
    n:persistent()
    n:on_dismiss(function()
        print("Joueur a pris connaissance du message")
    end)
end)
```

---

## Position

La position est configurée dans les **Paramètres utilisateur** (F12) :

| Axe | Options |
|---|---|
| X | `left` / `right` |
| Y | `top` / `bottom` |

Par défaut : `bottom-right`.

---

## Comportement

Les notifications s'empilent — chacune se ferme indépendamment après sa `duration`. Il n'y a pas de limite au nombre de toasts simultanés (configurable dans les paramètres utilisateur). Elles ne volent jamais le focus NUI.
