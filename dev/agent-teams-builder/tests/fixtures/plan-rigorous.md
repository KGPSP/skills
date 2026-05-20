# Plan — retro-forge

<!-- GOOD fixture — wszystkie 11 sekcji obecne, 3 hipotezy per sprint, 2+ alternatives. -->
<!-- Expected: verify-plan-rigor.sh exit 0 -->

## 1. Goal (business)

Webowy kreator gier retro 2D w 30 minut bez wiedzy programistycznej.

## 2. Sprints

### Sprint 1 — Bootstrap + landing

**Goal (business):** User widzi stronę startową, klika "New Project", trafia do edytora.

**Hipotezy podejścia (3 wymagane):**

| # | Nazwa | Opis | Trade-offs | Hyrum risk | Koszt (h) |
|---|---|---|---|---|---|
| H1 | **Minimal** | Statyczny HTML | Brak deps, szybkie. Brak DX. | brak | 2h |
| H2 | **Idiomatic** | React + Vite | Standard, hot reload | brak | 4h |
| H3 | **Ambitious** | Next.js 15 + RSC | SSR, SEO. Overkill MVP. | niski | 8h |

**Wybór:** H2 (Idiomatic).

**Uzasadnienie wg 5 Non-negotiables:**
- **#3 Nudne rozwiązania:** React + Vite to standard branżowy.
- Hyrum: nowy projekt, brak consumers.

**Odrzucone:** H1 (brak DX), H3 (over-engineering bez requirements SSR).

### Sprint 2 — Editor canvas

**Goal (business):** User rysuje poziom drag-drop kafelków na siatce.

**Hipotezy podejścia (3 wymagane):**

| # | Nazwa | Opis | Trade-offs | Hyrum risk | Koszt (h) |
|---|---|---|---|---|---|
| H1 | **Minimal** | Canvas 2D + manual mouse events | Pełna kontrola. Brak undo. | brak | 6h |
| H2 | **Idiomatic** | react-dnd + HTML5 backend | Standard, undo darmowy. +50KB. | brak | 10h |
| H3 | **Ambitious** | Phaser 3 Scene + InputPlugin | Future-proof. Heavy. | średni | 16h |

**Wybór:** H2.

**Uzasadnienie:** Idiomatic balance, undo gratis, accessibility OK.

**Odrzucone:** H1 (brak undo to dług), H3 (overkill MVP, zachowane jako future).

### Sprint 3 — Asset palette

**Goal (business):** User wybiera spritesy z 5 palet.

**Hipotezy podejścia (3 wymagane):**

| # | Nazwa | Opis | Trade-offs | Hyrum risk | Koszt (h) |
|---|---|---|---|---|---|
| H1 | **Minimal** | Static JSON manifest | Prostota. Brak lazy loading. | brak | 3h |
| H2 | **Idiomatic** | Dynamic import + manifest | Lazy, code-split. | brak | 5h |
| H3 | **Ambitious** | CDN + Service Worker cache | PWA-ready. Komplikacja. | niski | 12h |

**Wybór:** H2.

**Odrzucone:** H1 (zbyt sztywne), H3 (out-of-scope PWA).

## 3. Dependencies

| Typ | Co | Wersja (context7) | Library ID |
|---|---|---|---|
| Lib | React | 19.0.0 | /facebook/react |
| Lib | Vite | 5.4.0 | /vitejs/vite |
| Lib | react-dnd | 16.0.1 | /react-dnd/react-dnd |
| Lib | Playwright | 1.42.0 | /microsoft/playwright |

## 4. Open Questions

- [ ] Czy export ma być HTML czy zip? → decyzja przed sprintem 6
- [ ] Mobile support? → desktop-only, decyzja przed sprintem 1 (resolved: NO)

## 5. Out of scope

- Multiplayer
- Eksport do Electron
- i18n (tylko PL/EN)

## 6. Success metric

- [ ] User w 30 min buduje grywalną grę 2D
- [ ] 6 sprintów: passed
- [ ] CHANGELOG + tag v0.1.0

## 7. Ryzyka

| Ryzyko | Prawdopodobieństwo | Wpływ | Severity | Mitigation |
|---|---|---|---|---|
| react-dnd API breaking changes | L | H | Medium | context7 lock version + smoke test |
| Bundle size > 1MB | M | M | Medium | Webpack analyzer w fazie 6 |
| AI slop w design | H | L | Low | Few-shot rubric/examples/ |

## 8. Recommendation summary

**Architektura:** SPA React + Vite, lokalny state przez Context API.

**Kluczowe decyzje:**
1. State: lokalny `useState` + `EditorContext` (NIE Redux — overhead).
2. Rendering: React DOM. Bez Phaser w MVP — może w v0.2.0.
3. Persistencja: localStorage (offline-first, brak backendu).

## 9. Hyrum Impact

| Sprint | Co zmienia | Consumers | Klasyfikacja | Mitigation |
|---|---|---|---|---|
| 5 | localStorage schema v1 | 0 (nowy projekt) | **Internal** | Schema versioning w samym JSON |
| 6 | HTML export format | 0 | **Internal** | n/a |

## 10. Rollback plan

| Sprint | Strategia |
|---|---|
| 1 | `git revert` — landing izolowany |
| 2 | Feature flag `ENABLE_EDITOR_V2` |
| 3 | `git revert` — palettes static |
| 4 | Feature flag `ENABLE_PLAY_MODE` |
| 5 | Schema versioned — downgrade frontu wymagany |
| 6 | Pure function — `git revert` bez konsekwencji |

## 11. Alternatives considered

| Alternatywa | Dlaczego odrzucona | Re-consider? |
|---|---|---|
| Vue 3 + Pixi.js | Stack ekipy = React/Phaser | NIE |
| Native Godot export | Out of scope — web-first | NIE |
| Next.js SSR | Editor wymaga JS runtime | NIE |
| PWA + IndexedDB | Out of scope MVP | TAK — po v0.2.0 |
