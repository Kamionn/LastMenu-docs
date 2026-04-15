---
title: LastMenu
description: Sistema di menu universale per FiveM — zero dipendenze, un'API, reattività in tempo reale.
order: 0
---

## Cos'è LastMenu?

**LastMenu** è una libreria UI completa per FiveM. Unifica tutti i tipi di menu comuni (contestuale, radiale, modulo di input, avviso, notifica, barra di progresso, target) sotto una **API builder coerente**, senza richiedere `ox_lib`, `qbx_core` o qualsiasi altro framework.

L'UI Svelte 5 è **precompilata** in `ui/assets/` — nessun `npm install` richiesto lato server di gioco.

## Perché LastMenu?

| Problema comune | Soluzione |
|---|---|
| Dipendenza da `ox_lib` o un framework | Zero dipendenze runtime |
| API diverse per tipo di menu | Un pattern builder per tutto |
| Nessuna reattività — chiudere/riaprire per aggiornare | Motore di polling reattivo integrato |
| Bloccato a un framework (ESX / QBCore) | Funziona in qualsiasi ambiente |