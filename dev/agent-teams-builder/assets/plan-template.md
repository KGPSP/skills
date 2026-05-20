# Plan — <nazwa projektu>

> Szablon dla `state/plan.md`. Wypełnia **Planner** w fazie 1 SKILL.md. Nie zawiera szczegółów technicznych — to robota Generatora pod feedbackiem Evaluatora.

---

## Goal (business)

<jednolinijkowy opis tego, co użytkownik dostaje>

Przykład:
> "Webowy kreator gier retro, w którym użytkownik buduje 2D platformer w 30 minut bez wiedzy programistycznej."

---

## Sprints

| # | Sprint | Cel biznesowy (mierzalny) |
|---|---|---|
| 1 | Bootstrap + landing | User widzi stronę startową, klika "New Project", trafia do edytora |
| 2 | Editor canvas | User rysuje poziom przez drag-drop kafelków na siatce 32x18 |
| 3 | Asset palette | User wybiera spritesy z 5 palet (retro/cyberpunk/forest/desert/space) |
| 4 | Play mode | User klika "Play", gra startuje, strzałki + spacja działają |
| 5 | Save/Load | User zapisuje projekt do localStorage, odtwarza po F5 |
| 6 | Export to HTML | User pobiera self-contained HTML działający offline |

**Granulacja:** 3-15 sprintów. Mniej = mikromanagement. Więcej = agenci się gubią → rozbij na fazy projektu (każda = osobne `state/`).

---

## Dependencies

| Typ | Co | Źródło/wersja |
|---|---|---|
| Biblioteka | React 18 | npm |
| Biblioteka | Phaser 3 (game engine) | npm |
| Biblioteka | Playwright (do testów Evaluatora) | npm |
| API zewnętrzne | (brak — aplikacja offline-first) | — |
| Dane | 5 palet sprite assets | repo `/public/assets/` |

---

## Open Questions

> Non-negotiable #1: uwidaczniaj założenia przed budowaniem.

- [ ] Czy export ma być pojedynczym HTML czy zip-em z assets/? → **decyzja human przed sprintem 6**
- [ ] Czy zapisywanie ma być per-projekt czy auto-save? → **decyzja human przed sprintem 5**
- [ ] Czy obsługujemy mobile? → **NIE — sprint 0 zakłada desktop-only**

Sekcja Open Questions **nie może być pusta** bez świadomej deklaracji "brak". Pusty = sygnał ostrzegawczy (Planner założył coś bez świadomości).

---

## Out of scope (cała sesja)

- Multiplayer / sieciowe rozgrywki.
- Eksport do natywnych aplikacji (Electron / Capacitor).
- Monetyzacja / IAP.
- i18n (tylko polski/angielski).

---

## Success metric (definicja zakończenia)

- [ ] User w 30 minut buduje grywalną grę 2D od zera.
- [ ] Wszystkie 6 sprintów: `passed`.
- [ ] CHANGELOG zaktualizowany, tag v0.1.0 wystawiony.

---

## Ryzyka

| Ryzyko | Prawdopodobieństwo | Wpływ | Mitygacja |
|---|---|---|---|
| Phaser 3 ma niespójne API klawiatury | średnie | duży | Smoke test klawiatury w sprincie 1, nie 4 |
| Performance edytora przy dużych poziomach | niskie | średni | Sprint 2: limit 100x50 kafelków |
| AI slop w UI palette | wysokie | mały | Few-shot w rubric/examples/ |

---

## Notes for Generator/Evaluator

- **Generator:** wybór bibliotek poza tymi w Dependencies wymaga ADR w `docs/adr/`.
- **Evaluator:** rubric design zawsze odnosi się do `assets/rubric-example.md` — retro aesthetic, NIE generic SaaS.
- **Wszystkie agenty:** każdy sprint kończy się `passed` PRZED rozpoczęciem następnego. Brak parallel sprint w tej sesji.
