# Plan — <nazwa projektu>

> Szablon dla `state/plan.md` (wzbogacony v1.5 — dziedziczone z audited-feature-workflow).
> Wypełnia **Planner** w fazie 1 SKILL.md. Walidator: `scripts/verify-plan-rigor.sh`.

---

## 1. Goal (business)

<jednolinijkowy opis tego, co użytkownik dostaje>

Przykład:
> "Webowy kreator gier retro, w którym użytkownik buduje 2D platformer w 30 minut bez wiedzy programistycznej."

---

## 2. Sprints

<!-- Każdy sprint MA mieć 3 hipotezy (Minimal/Idiomatic/Ambitious) + wybór + uzasadnienie. -->
<!-- Walidator: heurystyka tabeli z >=3 wierszami per sprint. -->

### Sprint 1 — <nazwa>

**Goal (business):** <mierzalny cel biznesowy>

**Hipotezy podejścia (3 wymagane):**

| # | Nazwa | Opis | Trade-offs | Hyrum risk | Koszt (h) |
|---|---|---|---|---|---|
| H1 | **Minimal** | <najmniejszy ruch> | Pro: ... Con: ... | brak/niski/średni/wysoki | Nh |
| H2 | **Idiomatic** | <zgodne z konwencją repo> | Pro: ... Con: ... | brak/niski/średni/wysoki | Nh |
| H3 | **Ambitious** | <przyszłościowe> | Pro: ... Con: ... | brak/niski/średni/wysoki | Nh |

**Wybór:** H<X>.

**Uzasadnienie wg 5 Non-negotiables:**
- **#1 Założenia:** <jakie założenia są jawne>
- **#3 Nudne rozwiązania:** <dlaczego wybór jest nudny/branżowy>
- Hyrum: <breaking/additive/internal>

**Odrzucone:** <powód odrzucenia H1 i H3 + czy zachowane jako future consideration>

### Sprint 2 — <nazwa>
<analogicznie 3 hipotezy + wybór>

<!-- 3-15 sprintów total. Mniej = mikromanagement. Więcej = agenci się gubią. -->

---

## 3. Dependencies

| Typ | Co | Wersja (zweryfikowana przez context7) | Library ID |
|---|---|---|---|
| Lib | React | 19.0.0 | /facebook/react |
| Lib | Phaser 3 | 3.70.0 | /photonstorm/phaser |
| Lib | Playwright | 1.42.0 | /microsoft/playwright |
| API zewnętrzne | (brak — aplikacja offline-first) | — | — |
| Dane | 5 palet sprite assets | repo `/public/assets/` | — |

<!-- Wszystkie dep weryfikowane przez context7 w fazie 1 → breadcrumb library_currency_checked. -->
<!-- Patrz: references/library-currency-protocol.md -->

---

## 4. Open Questions

<!-- Non-negotiable #1: uwidaczniaj założenia przed budowaniem. -->
<!-- Sekcja NIE moze byc pusta bez swiadomej deklaracji "no open questions". -->

- [ ] Czy export ma być pojedynczym HTML czy zip-em z assets/? → decyzja human przed sprintem 6
- [ ] Czy zapisywanie ma być per-projekt czy auto-save? → decyzja human przed sprintem 5

---

## 5. Out of scope (cała sesja)

- Multiplayer / sieciowe rozgrywki
- Eksport do natywnych aplikacji (Electron / Capacitor)
- Monetyzacja / IAP
- i18n (tylko polski/angielski)

---

## 6. Success metric (definicja zakończenia)

- [ ] User w 30 minut buduje grywalną grę 2D od zera
- [ ] Wszystkie 6 sprintów: `passed`
- [ ] CHANGELOG zaktualizowany, tag v0.1.0 wystawiony

---

## 7. Ryzyka (skalowane H/M/L + mitigation)

| Ryzyko | Prawdopodobieństwo | Wpływ | Severity | Mitigation |
|---|---|---|---|---|
| Phaser 3 ma niespójne API klawiatury | M | H | **High** | Smoke test klawiatury w sprincie 1 (wcześnie), nie 4 |
| Performance edytora przy dużych poziomach | L | M | Medium | Sprint 2: limit 100x50 kafelków, perf check w fazie 3 |
| AI slop w UI palette | H | L | Low | Few-shot w `state/rubric/examples/` przed sprintem 3 |
| context7 nie ma dokumentacji Phaser 3 | L | M | Medium | Fallback chain: DeepWiki → WebFetch phaser.io/docs |

---

## 8. Recommendation summary (top-level)

<!-- NOWA sekcja (v1.5) — dziedziczone z audited-feature-workflow Phase 3. -->

**Architektura ogólna:** Single-page React app z Phaser 3 jako embedded game engine. localStorage dla persistencji. Brak backendu (offline-first).

**Kluczowe decyzje:**
1. **State management:** lokalny `useState` + custom `EditorContext` (NIE Redux — overhead na projekt scope).
2. **Rendering:** Phaser Scene dla game mode, React DOM dla editor UI. **Decoupled** — komunikacja przez ref + custom events.
3. **Export:** Self-contained HTML z inlined Phaser via Webpack. ~600KB final bundle.

**Najbliższa decyzja human:** patrz Open Questions Q1 (HTML vs zip).

---

## 9. Hyrum Impact

<!-- NOWA sekcja (v1.5) — wymagana gdy ktorykolwiek sprint dotyka publicznych API / schema DB / wersji critical dep. -->

| Sprint | Co zmienia | Consumers | Klasyfikacja | Mitigation |
|---|---|---|---|---|
| 5 | Format `localStorage` key `retro-forge-project-{id}` (schema JSON v1) | 0 (nowy projekt) | **Internal** | Schema version w samym JSON — migracje przyszłe |
| 6 | Format HTML export — embedded `<script>` tag z game state | 0 (nowy projekt) | **Internal** | n/a |

<!-- Jeśli "no public API changes in tej sesji" — wpisz to JAWNIE. Brak sekcji = walidator warn. -->

---

## 10. Rollback plan (per sprint)

<!-- NOWA sekcja (v1.5). -->

| Sprint | Strategia rollback |
|---|---|
| 1 | `git revert {sprint-hash}` — landing page izolowany, brak side effects |
| 2 | Feature flag `ENABLE_EDITOR_V2`. Wyłączenie flagi = brak data loss |
| 3 | `git revert` — palettes static, brak migracji |
| 4 | Feature flag `ENABLE_PLAY_MODE` |
| 5 | Schema localStorage versioned — rollback wymaga downgrade frontu |
| 6 | Export HTML jest pure function (state → HTML) — `git revert` bez konsekwencji |

---

## 11. Alternatives considered (top-level)

<!-- NOWA sekcja (v1.5) — min. 2 odrzucone architektury top-level. -->

| Alternatywa | Dlaczego odrzucona | Triggered re-consideration? |
|---|---|---|
| **Vue 3 + Pixi.js** | Stack ekipy = React/Phaser. Brak ekspertyzy w Pixi. | NIE |
| **Native game engine (Godot/Unity export)** | Out of scope: web-first. User nie ma instalować nic. | NIE |
| **Server-side rendering** | Editor wymaga ciężkiego runtime JS, SSR nie pomaga. | NIE |
| **PWA z offline storage przez IndexedDB** | Out of scope (Sprint 0: desktop-only). | TAK — po MVP, sprint future "PWA mode" |

---

## Notes for Generator/Evaluator/playwright-runner

- **Generator:** wybór bibliotek poza tymi w Dependencies wymaga ADR w `docs/adr/`. Każdy nowy import → `mcp__context7__*` + breadcrumb.
- **Evaluator:** rubric design zawsze odnosi się do `assets/rubric-example.md` — retro aesthetic, NIE generic SaaS.
- **playwright-runner:** sprint 1 obowiązkowo smoke test klawiatury (mitigation Risk #1 z sekcji 7).
- **Wszystkie agenty:** każdy sprint kończy się `passed` PRZED rozpoczęciem następnego. Brak parallel sprints.
