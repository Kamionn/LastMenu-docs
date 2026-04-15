---
title: Installation
description: Installez LastMenu sur un serveur FiveM — fxmanifest, server.cfg et structure des fichiers.
order: 1
lastUpdated: 2026-04-14
---

## Prérequis

- Un serveur **FiveM** fonctionnel (build ≥ 6683 recommandé)
- Aucun framework requis — LastMenu est **standalone**

## Étape 1 — Copier la ressource

Copiez le dossier `LastMenu` dans le répertoire `resources/` de votre serveur :

```
resources/
└── LastMenu/
    ├── client/
    ├── ui/
    ├── fxmanifest.lua
    └── ...
```

## Étape 2 — Déclarer dans server.cfg

Dans votre `server.cfg`, assurez-vous que LastMenu est chargé **avant** toute ressource qui l'utilise :

```
ensure LastMenu
```

> **Ordre de chargement critique.** Si une ressource dépendante démarre avant LastMenu, ses exports ne seront pas disponibles et vous obtiendrez des erreurs `attempt to call a nil value`.

## Étape 3 — Déclarer l'export dans vos ressources

Dans le `fxmanifest.lua` de **chaque ressource client** qui utilise LastMenu, ajoutez :

```lua
client_scripts {
    '@LastMenu/client/exports.lua',
    -- vos propres scripts...
    'client/*.lua',
}
```

C'est tout. Pas de `npm install`, pas de build côté serveur — l'UI est précompilée.

## Étape 4 — Référence rapide