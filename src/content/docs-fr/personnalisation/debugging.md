---
title: Débogage
description: Activer le mode debug, utiliser les commandes console, diagnostiquer les erreurs de watcher et les problèmes de communication NUI.
order: 3
lastUpdated: 2026-04-14
---

## Activer le mode debug

Dans `client/config.lua` :

```lua
Config.debug = true
```

En mode debug, LastMenu affiche dans la console de la ressource :
- Compteurs d'évaluation / patch / erreurs des watchers, toutes les 60 ticks par menu actif
- Tentatives de récupération après Safe Mode
- Avertissements de validation de type depuis les builders (mauvais types passés à `field.min`, etc.)

Pour déboguer spécifiquement le **système target** (dessine les contours de zone en jeu) :

```lua
Config.debugTarget = true
```

---

## Commandes console

### `/lm_debug`

Affiche un snapshot de l'état de tous les watchers actifs dans la **console serveur** :

```
[LastMenu] ── Watcher stats ──────────────────────────
  Menu: 1735000000_1
    cb=cb_1735000000_1_shop_item_1   field=disabled  interval=500ms  errors=0  status=ok
    cb=cb_1735000000_1_shop_item_2   field=visible   interval=500ms  errors=2  status=ok
    cb=cb_1735000000_1_shop_item_3   field=disabled  interval=500ms  errors=3  status=retry@1735015000
[LastMenu] ─────────────────────────────────────────
```

**Valeurs de status :**

| Status | Signification |
|---|---|
| `ok` | Watcher actif et healthy |
| `DISABLED` | Safe Mode actif — indique un bug dans `reactive.lua` si aucun retryAt |
| `retry@<timestamp>` | Safe Mode actif — récupération tentée quand `GetGameTimer()` atteint cette valeur |

### Via export (depuis une autre ressource)

```lua
exports.LastMenu:debug_stats()
```

---

## Lire les erreurs de watcher

Quand une fonction watcher lève une erreur 3 fois de suite :

```
[LastMenu] Watcher DISABLED [1735000000_1:disabled] — will retry in 15s.
Error: attempt to index a nil value (global 'playerData')
```

Le message d'erreur est l'erreur Lua lancée par la fonction watcher.

| Message d'erreur | Cause probable |
|---|---|
| `attempt to index a nil value` | Accès à une variable non encore initialisée |
| `attempt to perform arithmetic on a nil value` | Nombre utilisé avant d'être défini |
| `stack overflow` | Récursion infinie dans le watcher |
| `bad argument #1 to 'X'` | Mauvais type passé à un natif ou une fonction |

---

## Diagnostiquer la communication NUI

Si un menu s'ouvre mais que les boutons ne répondent pas :

**1. Ouvre les Chromium DevTools NUI** : dans FiveM, entre `nui_devtools` dans la console F8 (builds de développement uniquement).

**2. Onglet Console** — cherche les erreurs JavaScript.

**3. Onglet Network** — les messages NUI apparaissent comme des appels `fetch` vers `https://lastmenu/`.

**4. Vérifie** que `Bridge.onCallback` enregistre le bon `cb_id` — consulte la console Lua pour les messages `[LastMenu] ...` pendant la séquence d'ouverture.

---

## Symptômes courants

### Le menu s'ouvre mais se ferme immédiatement

- Vérifie que `Stack.pop()` n'est pas appelé deux fois (ex. : `onComplete` et le handler de complétion par défaut sont tous les deux enregistrés — n'en utilise qu'un).
- Vérifie qu'une autre ressource n'appelle pas `lastmenu_back` de façon inattendue.

### Le focus NUI reste bloqué après le redémarrage d'une ressource

La ressource s'est arrêtée pendant qu'un menu était ouvert et `onResourceStop` n'a pas eu le temps de s'exécuter. Solutions :

1. Exécute `SetNuiFocus(false, false)` depuis la console F8.
2. Redémarre la ressource LastMenu.
3. Appelle `exports.LastMenu:lastmenu_back()` depuis une autre ressource.

### Les watchers cessent de se mettre à jour après quelques secondes

Safe Mode déclenché. Exécute `/lm_debug` pour voir quel watcher est désactivé et quelle erreur il a levée. Corrige la fonction watcher — le menu se récupèrera automatiquement dans les 15s.

### `UI:alert_async` / `UI:input_async` retourne `false` immédiatement

Appelé hors d'une coroutine. Encapsule l'appel dans un `Citizen.CreateThread`. Voir [Pièges courants](/docs/personnalisation/pitfalls#3-appeler-async-hors-dune-coroutine).

---

## Inspecter la stack

```lua
-- Depuis une callback ou un watcher :
-- LastMenu.Stack.peek() retourne { id, type, level, nav } ou nil
-- Les valeurs de type sont : 'context', 'alert', 'input', 'progress', 'radial', 'target'
```

La stack est côté NUI (`$state` dans `App.svelte`). Lua maintient un compteur miroir pour la gestion du curseur et du focus.
