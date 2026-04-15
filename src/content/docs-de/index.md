---
title: LastMenu
description: Universelles Menüsystem für FiveM — null Abhängigkeiten, eine API, Echtzeit-Reaktivität.
order: 0
---

## Was ist LastMenu?

**LastMenu** ist eine vollständige UI-Bibliothek für FiveM. Sie vereinheitlicht alle gängigen Menütypen (Kontext, radial, Eingabeformular, Alert, Benachrichtigung, Fortschrittsbalken, Target) unter einer **konsistenten Builder-API**, ohne `ox_lib`, `qbx_core` oder irgendein anderes Framework zu benötigen.

Die Svelte 5 UI ist **vorkompiliert** in `ui/assets/` — kein `npm install` auf der Server-Seite erforderlich.

## Warum LastMenu?

| Häufiges Problem | Lösung |
|---|---|
| Abhängigkeit von `ox_lib` oder einem Framework | Null Laufzeitabhängigkeiten |
| Verschiedene APIs pro Menütyp | Ein Builder-Pattern für alles |
| Keine Reaktivität — schließen/öffnen zum Aktualisieren | Integrierte reaktive Polling-Engine |
| Gebunden an ein Framework (ESX / QBCore) | Funktioniert in jeder Umgebung |