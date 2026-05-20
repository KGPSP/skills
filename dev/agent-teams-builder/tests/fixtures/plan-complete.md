# Plan — retro-forge

> GOOD fixture — wszystkie wymagane sekcje, Open Questions niepuste (Non-negotiable #1 zachowane).
> Expected: scripts/verify-non-negotiables.sh exit 0 (pod warunkiem braku open blockers).

## Goal (business)

Webowy kreator gier retro 2D w którym użytkownik buduje grywalną platformer w 30 minut bez wiedzy programistycznej.

## Sprints

| # | Sprint | Cel biznesowy |
|---|---|---|
| 1 | Bootstrap + landing | User widzi stronę startową, klika "New Project", trafia do edytora |
| 2 | Editor canvas | User rysuje poziom przez drag-drop kafelków na siatce 32x18 |
| 3 | Asset palette | User wybiera spritesy z 5 palet |
| 4 | Play mode | User klika "Play", gra startuje, strzałki + spacja działają |
| 5 | Save/Load | User zapisuje projekt do localStorage |
| 6 | Export to HTML | User pobiera self-contained HTML |

## Dependencies

| Typ | Co | Wersja |
|---|---|---|
| Lib | React | 18.x |
| Lib | Phaser 3 | 3.70 |
| Lib | Playwright | 1.42 |

## Open Questions

- [ ] Czy export ma być pojedynczym HTML czy zip-em? → decyzja human przed sprintem 6
- [ ] Czy zapisywanie ma być per-projekt czy auto-save? → decyzja human przed sprintem 5
- [ ] Czy obsługujemy mobile? → NIE — sprint 0 zakłada desktop-only

## Out of scope (cała sesja)

- Multiplayer
- Eksport do natywnych aplikacji (Electron)
- Monetyzacja
- i18n

## Success metric

- [ ] User w 30 minut buduje grywalną grę 2D
- [ ] Wszystkie 6 sprintów: `passed`
- [ ] CHANGELOG zaktualizowany, tag v0.1.0
