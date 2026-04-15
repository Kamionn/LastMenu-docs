---
title: Pièges courants
description: Anti-patterns fréquents lors de l'utilisation de LastMenu — causes, symptômes et corrections.
order: 4
lastUpdated: 2026-04-14
---

## 1. Watcher retournant une table

**Problème** — Comparer des tables avec `~=` utilise l'égalité de référence. Une fonction qui retourne une **nouvelle table à chaque tick** est toujours perçue comme "changée", ce qui envoie un patch NUI à chaque cycle de polling.

```lua
-- MAUVAIS : nouvelle table à chaque tick → patches constants
menu:button('Statut', {
    disabled = function()
        return { locked = isLocked() }  -- table, pas un booléen !
    end,
})
```

```lua
-- CORRECT : retourne un primitif
menu:button('Statut', {
    disabled = function() return isLocked() end,
})
```

LastMenu affiche un avertissement console unique quand ce pattern est détecté. Vérifie la console de ta ressource si tu observes une fréquence de messages NUI anormalement élevée.

---

## 2. Labels dupliqués dans le même menu

Depuis v1.0.0, les `cb_id` sont dérivés du label (slugifié) et non de la position d'insertion. `menu:button('Acheter', ...)` obtient toujours le slug `cb_<menu_id>_acheter` quel que soit l'ordre.

Si **deux items ont exactement le même label**, LastMenu ajoute automatiquement `_2`, `_3`, etc. — les callbacks restent corrects, mais si l'un de ces items est réactif, le patch n'atteindra le bon item que si l'ordre est stable entre les rebuilds.

```lua
-- Bien : labels uniques → slugs stables
menu:button('Acheter',  { cb = fn1 })
menu:button('Vendre',   { cb = fn2 })

-- Fonctionne, mais "Action_2" obtient le slug action_2 — garde l'ordre stable
menu:button('Action', { cb = fn1 })
menu:button('Action', { cb = fn2, disabled = function() return onCooldown() end })

-- Meilleure pratique : utilise opts.id pour épingler une clé explicite
menu:button('Action', { id = 'action_acheter', cb = fn1 })
menu:button('Action', { id = 'action_vendre',  cb = fn2, disabled = function() return onCooldown() end })
```

---

## 3. Appeler `*_async` hors d'une coroutine

`UI:alert_async` et `UI:input_async` appellent `coroutine.yield()` en interne. Ils **doivent** être appelés depuis un `Citizen.CreateThread`. Depuis un handler d'événement ou un callback non-coroutine, ils affichent une erreur et retournent `nil`/`false` immédiatement.

```lua
-- MAUVAIS : handler d'événement classique (pas une coroutine)
AddEventHandler('monEvenement', function()
    local ok = exports.LastMenu:alert_async(function(b) ... end)  -- retourne false
end)

-- CORRECT : wrappé dans un thread
AddEventHandler('monEvenement', function()
    Citizen.CreateThread(function()
        local ok = exports.LastMenu:alert_async(function(b) ... end)
        if ok then ... end
    end)
end)
```

---

## 4. Watcher `visible`/`disabled` retournant autre chose qu'un booléen

Ces champs attendent un **booléen**. Retourner une table, une chaîne, ou `nil` empêche l'enregistrement du watcher et affiche un avertissement.

```lua
-- MAUVAIS : visible attend un booléen, pas une table
menu:button('Acheter', { visible = function() return getPlayerData() end })

-- CORRECT
menu:button('Acheter', { visible = function() return getPlayerData() ~= nil end })
```

---

## 5. `default` vs `value` dans les champs input

Les champs input utilisent `opts.default` (et non `opts.value`) pour la valeur pré-remplie. Cette convention correspond à la sémantique HTML `<input defaultValue>` — le joueur peut la modifier.

```lua
-- CORRECT
form:field('Montant', { type = 'number', default = 100 })

-- MAUVAIS (ignoré silencieusement)
form:field('Montant', { type = 'number', value = 100 })
```

---

## 6. Redémarrage de ressource avec menu ouvert

Si une ressource s'arrête pendant qu'un menu est ouvert, LastMenu libère le focus NUI et nettoie la stack dans `onResourceStop`. Cependant, si ton code appelle `Stack.pop()` ou `Stack.clear()` depuis le `onResourceStop` d'une ressource **externe**, le focus NUI peut rester bloqué — le message NUI différé de fermeture n'est plus traité.

**Solution** : ferme les menus avant d'arrêter les ressources dépendantes, ou appelle `exports.LastMenu:lastmenu_back()` pour une fermeture propre.

---

## 7. Appeler `UI_Context_Update` sans menu contextuel actif

`UI_Context_Update` lit `Stack.peek()`. Si le sommet de la stack n'est pas un menu contextuel (ou si la stack est vide), l'appel ne fait **rien** — comportement intentionnel. Si ta mise à jour ne s'applique pas, vérifie que `Stack.peek().type == 'context'`.

---

## 8. Safe Mode du watcher — désactivation permanente

Après 3 erreurs consécutives dans une fonction watcher, LastMenu entre en **Safe Mode** pour ce watcher : désactivation pendant 15 secondes, puis une tentative de récupération. Si l'erreur persiste, désactivation à nouveau.

**Symptômes** : l'état `visible`/`disabled` d'un bouton cesse de se mettre à jour, fait une brève mise à jour, puis s'arrête à nouveau.

**Diagnostic** : recherche les messages `[LastMenu] Watcher DISABLED` dans la console. Active `Config.debug = true` ou exécute `/lm_debug` pour des statistiques détaillées.

**Causes fréquentes** :
- Accès à `playerData` avant l'initialisation du joueur
- Appels natifs invalides (entité supprimée, ped nil)
- Récursion non intentionnelle dans la fonction watcher

---

## 9. `keep_open` manquant sur le bouton parent d'un sous-menu

Sans `keep_open = true`, le menu parent se ferme **avant** l'ouverture du sous-menu, cassant la stack de navigation.

```lua
-- MAUVAIS : parent se ferme, sous-menu se retrouve seul
menu:button("Options", {
    cb = function()
        UI:context(function(sub) ... end)
    end,
})

-- CORRECT
menu:button("Options", {
    arrow     = true,
    keep_open = true,
    cb        = function()
        UI:context(function(sub) ... end)
    end,
})
```

Avec le helper `menu:submenu(...)`, `keep_open` est positionné automatiquement.

---

## 10. `persist_key` manquant avec label dynamique et cooldown

La clé de persistance du cooldown est dérivée du `label + cooldown` par défaut. Si le label est dynamique (contient un nom de joueur, une variable...), la clé change et le cooldown ne persiste plus correctement entre les sessions.

```lua
-- Problème : label dynamique → persist_key change à chaque rechargement
menu:button("Payer " .. playerName, {
    cooldown = 30000,
    cb       = function() end,
})

-- Solution : spécifier une persist_key stable
menu:button("Payer " .. playerName, {
    cooldown    = 30000,
    persist_key = "pay_player_" .. playerId,
    cb          = function() end,
})
```
