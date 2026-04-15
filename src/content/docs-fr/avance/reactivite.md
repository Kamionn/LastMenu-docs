---
title: Réactivité temps réel
description: Moteur de polling diff/patch — labels dynamiques, visible et disabled réactifs sans boucle de rendu manuelle.
order: 1
lastUpdated: 2026-04-14
---

## Principe

LastMenu intègre un **moteur de polling** qui surveille les fonctions déclarées dans tes builders. Quand la valeur retournée change, un **patch** minimal est envoyé à la NUI — pas de re-render global, pas de fermeture/réouverture du menu.

Aucune boucle `Citizen.Wait(0)` n'est nécessaire dans ton code.

---

## Label dynamique

Passe une **fonction** comme label d'un bouton pour qu'il se mette à jour en temps réel :

```lua
local startTime = GetGameTimer()

UI:context(function(menu)
    menu:title("Informations en direct")

    -- Mis à jour toutes les secondes
    menu:button(function()
        local elapsed = math.floor((GetGameTimer() - startTime) / 1000)
        return string.format("Ouvert depuis : %ds", elapsed)
    end, { refresh = 1000 })

    -- Affiche l'argent du joueur
    menu:button(function()
        return "Solde : " .. GetPlayerMoney(PlayerId()) .. " €"
    end, { refresh = 500 })
end)
```

---

## Visibilité réactive

```lua
-- Visible uniquement si le joueur est dans un véhicule
menu:button("Régler le régulateur de vitesse", {
    icon    = "gauge",
    visible = function()
        return GetVehiclePedIsIn(PlayerPedId(), false) ~= 0
    end,
    refresh = 250,
    cb      = function() end,
})
```

---

## Désactivation réactive

```lua
-- Désactivé pendant le cooldown
local lastUse = 0

menu:button("Utiliser l'objet", {
    icon     = "package",
    disabled = function()
        return (GetGameTimer() - lastUse) < 10000
    end,
    refresh = 250,
    cb      = function()
        lastUse = GetGameTimer()
        -- ...
    end,
})
```

---

## La propriété `refresh`

`refresh` (ms) contrôle la fréquence d'évaluation des fonctions de watcher.

| Champ | Défaut | Minimum recommandé |
|---|---|---|
| `label` (fonction) | `500ms` | `100ms` |
| `visible` | `250ms` | `100ms` |
| `disabled` | `250ms` | `100ms` |
| `stat.value` | `500ms` | `100ms` |

Descendre sous `100ms` est possible mais peu utile — la NUI n'affiche qu'à ~60 FPS.

---

## Valeurs `stat` réactives

Les propriétés `value` et `max` d'un item `stat` acceptent des fonctions :

```lua
menu:stat("Santé", {
    value   = function() return GetEntityHealth(PlayerPedId()) - 100 end,
    max     = 100,
    icon    = "heart",
    suffix  = "hp",
    refresh = 500,
})

menu:stat("Moteur", {
    value   = function()
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        return veh ~= 0 and GetVehicleEngineHealth(veh) / 10 or 0
    end,
    max     = 100,
    icon    = "activity",
    suffix  = "%",
    refresh = 1000,
})
```

---

## Safe Mode des watchers

Si une fonction watcher lève une erreur **3 fois de suite**, LastMenu entre en **Safe Mode** pour ce watcher :

1. Le watcher est **désactivé** pendant 15 secondes.
2. Un message d'alerte est imprimé dans la console : `[LastMenu] Watcher DISABLED ...`.
3. Après 15s, une **tentative de récupération** est effectuée.
4. Si l'erreur persiste, le watcher est désactivé à nouveau.

**Symptôme** : l'état `visible`/`disabled` d'un bouton cesse de se mettre à jour, fait une brève mise à jour, puis s'arrête à nouveau.

**Diagnostic** : active `Config.debug = true` ou exécute `/lm_debug` pour voir les stats des watchers.

---

## Anti-pattern : retourner une table

> **Attention** : une fonction watcher qui retourne une **table** au lieu d'un primitif envoie un patch NUI à chaque tick, car la comparaison de tables utilise l'égalité de référence.

```lua
-- MAUVAIS : nouvelle table à chaque tick → patches constants
menu:button('Statut', {
    disabled = function()
        return { locked = isLocked() }  -- table, pas un booléen
    end,
})

-- CORRECT : retourne un primitif
menu:button('Statut', {
    disabled = function() return isLocked() end,
})
```

LastMenu affiche un avertissement console unique quand ce pattern est détecté.

---

## Mécanisme interne

1. Le watcher évalue la fonction de label / valeur.
2. Si le résultat **diffère** de la dernière valeur connue, un patch est construit.
3. Le patch est envoyé via `Bridge.send({ type='patch', id, changes={...} })`.
4. `App.svelte` l'applique en O(1) via une `Map` indexée par item id — pas de re-render global.

Les watchers démarrent à chaque `open()` d'un menu réutilisable et s'arrêtent à la fermeture.
