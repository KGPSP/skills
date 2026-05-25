# Changelog

Historia zmian na poziomie repozytorium. Per-skill detale → commit history poszczególnych folderów.

## [2026-05-25] legal/planowanie-wydatkow-it-psp — **migracja na klasyfikację UFP 2027+** (v1.1.0)

### Changed (BREAKING)

- **Pełna migracja klasyfikacji UFP** na nową klasyfikację stosowaną od planowania budżetu 2027 wg **rozporządzenia MFiG z 20.04.2026 (Dz.U. 2026 poz. 582)** i ustawy z 27.02.2026 (Dz.U. 2026 poz. 426). Paragrafy 3-cyfrowe (631/634/638/670/677/681/682/687/770/771/778 bieżące + 701/702/703/704/711/712/720 majątkowe) zamiast 4-cyfrowych legacy (4xxx/6xxx).
- **Próg 10 000 zł zlikwidowany** — polityka rachunkowości jednostki decyduje o kwalifikacji wydatku majątkowego, nie kwota.
- **Załącznik nr 4** (szczegółowość bezpieczeństwa wewnętrznego PSP): 631003, 634003/4, 670001, 687011, 702001/2, 704001, 712001/2, 778005/8/9.
- Pełny rewrite `references/klasyfikacja-budzetowa.md`: nowe matryce paragrafów (§5/§6), załącznik nr 4 (§7), 9 pułapek klasyfikacyjnych, klucz przejścia stara→nowa (§10).
- Migracja wszystkich pozostałych `references/`: katalog kosztów (15 sekcji A–O), przeliczenia walut/VAT, uzasadnienie 8-pkt (przykłady CEOZO § 682/720), polioc-ramy, anti-rationalization (nowa wymówka #21 dla § 704).

### Added

- **Walidator `check-cost-plan.sh` sprawdzenie 9 (nowe)** — egzekwowanie uzasadnienia operacyjnego dla pozycji w § 704 (specjalistyczny sprzęt bezpieczeństwa publicznego). Wymagane frazy w raport.md: „zadanie operacyjne" / „sprzęt specjalistyczny" / „dyspozytorski" / „łączność krytyczna" / „system ratowniczy" / „operacyjne PSP" (zgodnie z decyzją z dialogu: walidator egzekwuje uzasadnienie per pozycja).
- **Walidator — rozszerzona detekcja legacy** (sprawdzenie 1): paragrafy 4-cyfrowe (4xxx/6xxx) zamiast tylko § 4000.
- **Walidator — plan utrzymania ≥ 5 lat** (sprawdzenie 5): rozszerzone na nowe paragrafy majątkowe 2027+ (700–729).
- Wszystkie 3 fixtures zmigrowane na klasyfikację 2027+: GOOD A → exit 0/8✔, GOOD C → exit 0/6✔, BAD → exit 1/12 błędów.
- `legal-tools` plugin → **v1.3.0**, `marketplace.json` root → **v1.7.0**.

### Why

POLiOC 2027–2031 obejmuje cały okres **nowej klasyfikacji** stosowanej od planowania budżetu 2027 (Dz.U. 2026 poz. 582 wszedł w życie 29.04.2026). Skill v1.0.1 używał starej klasyfikacji (4xxx/6xxx z art. 16d CIT, próg 10k) — był nieaktualny dla okresu planowania, do którego jest przeznaczony. Migracja oparta na analizie BIŁ KG PSP (`Analiza_klasyfikacji_IT_KG_PSP_2027_BIL.docx`) i materiale edukacyjnym (`Material_edukacyjny_Finanse_publiczne_2026_BIL_KG_PSP.docx`) — stan 21.05.2026, wersja 1.0.

## [2026-05-25] legal/planowanie-wydatkow-it-psp — code review fixes (v1.0.1)

### Fixed (z code review)

- **Walidator `scripts/check-cost-plan.sh` (sprawdzenie 8 dodane)** — egzekwowanie `sum(G..L) = F` w tabeli XLSX (parser awk, 12 kolumn A..L). Wcześniej deklarowane w SKILL.md F6 jako „twarda walidacja XLSX", ale niezaimplementowane. `tests/fixtures/bad-plan.md` BŁĄD 7 (suma 1 000 000 ≠ F 1 225 000) teraz wykrywany.
- **Walidator (sprawdzenie 4, bug v1.0.0)** — heurystyka detekcji kwot > 100 000 zł brutto nigdy nie działała: `tr -d ' '` nie usuwało markdownowych `**` wokół etykiety „**Kwota brutto PLN:**", przez co regex `KwotabruttoPLN:[0-9]{6,}` nigdy nie matchował. Naprawiono na `tr -d ' *'`. Po naprawie sprawdzenie #4 (próg MSWiA z pkt 166 Programu OLiOC) faktycznie egzekwowane.
- **`templates/tabela-xlsx-uklad.md`** — utworzono brakujący plik (SKILL.md:237 wskazywał ścieżkę do nieistniejącego pliku). Zawiera układ A–L, mapę skrótów jednostek PSP, konwencje formatu, przykłady kompletnego wypełnienia.
- **Ścieżki absolutne `/Users/sq13pl/...`** — usunięto z `SKILL.md:247` i `templates/raport-skeleton.md:140` (anty-wzorzec wg DOC `since_skill.md` §6: skill po instalacji marketplace kopiuje się do `~/.claude/plugins/...`). Zastąpiono `sh scripts/check-cost-plan.sh ...` z komentarzem o uruchamianiu z katalogu skilla.
- **`SKILL.md` frontmatter `description`** — skondensowano z 1149 do 789 znaków (router-friendly, brak duplikacji 11 trigger phrases z `trigger:`).
- **`references/anti-rationalization.md` frontmatter** — `description` naprawiona „16 wymówek" → „20 wymówek" (zgodne z faktem i pozostałą dokumentacją).

### Added (testy + adnotacje)

- **`tests/fixtures/good-plan-tryb-c.md`** — fixture trybu C (754/75409, 4-pkt schemat). Beyoncé Rule: gałąź `--tryb C` walidatora ma teraz własny test (exit 0, 6 ✔).
- **`tests/fixtures/bad-plan.md`** — komentarze diagnostyczne BŁĄD 3 i BŁĄD 6 oczyszczone z trigger phrases walidatora (wcześniej tłumiły wykrywanie samych przez globalny grep). Po naprawie BAD wykrywa 10 błędów (poprzednio 8).
- **`SKILL.md` § Sources** — adnotacja, że `now_skille/` jest gitignored (analog `DOC/`); runtime skilla od niego niezależy.
- **`references/klasyfikacja-budzetowa.md` §6** — adnotacja o spójności: skrócona matryca w SKILL.md F4 to derywat §6–8 tego pliku; w razie rozbieżności źródłem prawdy jest plik referencyjny.
- **`legal-tools`** plugin → **v1.2.1** + **`marketplace.json`** root → **v1.6.1**.

## [2026-05-25] legal/planowanie-wydatkow-it-psp — nowy skill (v1.0.0)

### Added

- **`legal/planowanie-wydatkow-it-psp/`** — nowy skill wspierający krok-po-kroku przygotowanie wniosku finansowego / uzasadnienia wydatku / kosztorysu TCO dla systemu IT KG PSP. Procedura 6 faz (F1 Define → F2 Catalogize → F3 Price → F4 Classify → F5 Justify → F6 Verify+Ship) z exit criteria per faza.
- **Trzy tryby finansowania:** A (POLiOC cz. 42 obronne 752/75282 — domyślny), B (POLiOC podstawowy 754/75414), C (środki własne KG PSP poza POLiOC 754/75409).
- **7 plików `references/`:** katalog kosztów (15 sekcji A–O), klasyfikacja UFP, przeliczenia walut + VAT + reverse charge, 8-punktowy schemat uzasadnienia, ramy POLiOC 2027–2031, lista 19 małych kosztów + alokacja A/B/C, tabela 20 wymówek anti-rationalization.
- **`scripts/check-cost-plan.sh`** — POSIX-compliant walidator (7 sprawdzeń: § 4000, kurs NBP, 8-pkt uzasadnienie, opinia MSWiA > 100k, plan utrzymania ≥ 5 lat, reverse charge dla walut, klasyfikacja 752/75282).
- **`tests/fixtures/good-plan.md` + `bad-plan.md`** — fixture testowy: GOOD → exit 0 (6 ✔), BAD → exit 1 (7 błędów wykrytych).
- **`legal-tools`** plugin → **v1.2.0** + **`marketplace.json`** root → **v1.6.0**: opis legal-tools rozszerzony o trzeci skill.

### Materiał źródłowy

`now_skille/materialy_polioc/material_przeliczanie_kosztow.md` (11 części, ~1200 linii) + `Projekt-Programu-OLiOC-2027-2031-v17.DOCX` + `Propozycja zadań do POLiOC 2027-2031 cz.42.xlsx`. Weryfikacja aktów przez `legal/sejm-eli-api`: Dz.U. 2025 poz. 1483 (UFP), Dz.U. 2026 poz. 582 (klasyfikacja dochodów/wydatków), Dz.U. 2025 poz. 1185 (klasyfikacja części budżetowych), ustawa OLiOC z 5.12.2024 r.

## [2026-05-25] dev/planner-f → dev/feature-spec-planner — rename skilla (v1.1.0)

### Changed

- **`dev/planner-f/` → `dev/feature-spec-planner/`** — pełny rename skilla (folder + frontmatter `name: planner-f` → `name: feature-spec-planner`). `git mv` zachował historię plików.
- **`dev-tools`** plugin → `v1.5.0` + **`marketplace.json`** root → `v1.5.0`: opis dev-tools zaktualizowany (planning-only → `feature-spec-planner`).
- **Trigger keywords:** `"feature-spec-planner"` jako główny + **`"planner-f"` zachowany jako legacy alias** (backward-compat). `/plan-f` slash command nietknięty.
- **Cross-references zsynchronizowane** (~22 plików): manifesty, READMEs (root + dev/), AGENTS.md, 8× `parent:` w `references/`, komentarze w `scripts/`, cross-refs w `audited-feature-workflow`, `replit-style-workflow`, root CHANGELOG. Globalny `sed` zamienił wszystkie wystąpienia `planner-f` → `feature-spec-planner` poza `.git/`.

### Why

Po wcześniejszych renamach `feature-planner` → `replit-style-workflow` (v2.3.0) i `feature-planner-v3` → `audited-feature-workflow` (v3.3.0) — `planner-f` był jedynym skillem w `dev-tools` plugin ze **skrótowym, niejednoznacznym sufixem `-f`** (czy `final`? `finalize`? `feature`?). Łamało konsystencję naming convention. Nowa nazwa `feature-spec-planner`:
- **`feature`** — zakres (feature lifecycle)
- **`spec`** — kluczowy output (AC ↔ Test specification, DoD-spec)
- **`planner`** — zachowane powiązanie z planowaniem

Trzy `dev` workflow skille mają teraz opisowe nazwy (`replit-style-workflow` / `audited-feature-workflow` / `feature-spec-planner`) — naming convention spójna.

### Co NIE zmienia się

- **Funkcjonalność skilla** — pure rename refactor, zero zmian w SKILL.md content czy references.
- **Trigger keywords** — wszystkie zachowane: główny + legacy `"planner-f"` alias + `/plan-f` slash.
- **`derives-from: audited-feature-workflow`** — zachowane.
- **22/22 testów `agent-teams-builder/tests/run-meta-tests.sh`** — regresja sprawdzona.

### Migracja

Wywoływanie przez trigger phrasy → bez zmian. Wywoływanie przez `name:`: stare `planner-f` nadal działa (legacy trigger w SKILL.md), preferowane nowe `feature-spec-planner`.

## [2026-05-25] dev/feature-planner-v3 → dev/audited-feature-workflow — rename skilla (v3.3.0)

### Changed

- **`dev/feature-planner-v3/` → `dev/audited-feature-workflow/`** — pełny rename skilla (folder + frontmatter `name: feature-planner-v3` → `name: audited-feature-workflow`). `git mv` zachował historię plików.
- **`dev-tools`** plugin → `v1.4.0`: zaktualizowana lista `skills:` + keywords (+`audited-workflow`).
- **`marketplace.json`** root → `v1.4.0`: opis dev-tools odzwierciedla nową nazwę i pozycjonowanie (audit-trail-ready senior-grade vs replit-style wygodny).
- **Cross-references zsynchronizowane** (>40 plików, ~53 total z folder rename): manifesty, READMEs (root + dev/), AGENTS.md, wszystkie 13× `parent:` w `references/`, 3× komentarze w `scripts/`, cross-refs w `replit-style-workflow`, `feature-spec-planner`, `agent-teams-builder`, `swarm-orchestrator`. Globalny `sed` zamienił wszystkie wystąpienia `feature-planner-v3` → `audited-feature-workflow` poza `.git/`.

### Why

Po wcześniejszym renamie `feature-planner` → `replit-style-workflow` (v2.3.0 ten sam dzień), sufix `-v3` stracił semantykę sekwencji. Nazwa nie wskazywała na unikalną wartość: pełen audit trail (6 HITL approval gates, raw evidence per AC, breadcrumbs, Five-Axis Review, /goal mode hard caps). `audited-feature-workflow` jasno pozycjonuje skill względem `replit-style-workflow` (wygodny rygor) — dla zadań wymagających audytowalności (compliance, regulated environment, fragile ops).

### Co NIE zmienia się

- **Funkcjonalność skilla** — pure rename refactor, zero zmian w SKILL.md content czy references.
- **Trigger keywords** — `/goal`, `senior-grade feature`, `dodaj feature v3`, `ralph v3`, `implement v3` zachowane.
- **22/22 testów `agent-teams-builder/tests/run-meta-tests.sh`** — regresja sprawdzona po wszystkich zmianach.
- **Relacja `extends: replit-style-workflow`** — zachowana (audited rozszerza replit-style o senior-grade harness).

### Migracja

Wywoływanie przez trigger phrasy → bez zmian. Wywoływanie przez `name:` bezpośrednio → użyj `audited-feature-workflow` (nie `feature-planner-v3`).

### Historia paths w CHANGELOG-ach

Globalny `sed` zamienił wszystkie wystąpienia `feature-planner-v3` (włącznie ze ścieżkami w historycznych wpisach CHANGELOG-ów) → `audited-feature-workflow`. Konsekwencja: czytelnik CHANGELOG-a dziś nawiguje do current ścieżek; historia rename event jest zachowana w `git log` (commit + tag).

## [2026-05-25] dev/feature-planner → dev/replit-style-workflow — rename skilla (v2.3.0)

### Changed

- **`dev/feature-planner/` → `dev/replit-style-workflow/`** — pełny rename skilla (folder + frontmatter `name: feature-planner-v2` → `name: replit-style-workflow`). `git mv` zachował historię plików (rename detected przez gita).
- **`dev-tools`** plugin → `v1.3.0`: zaktualizowana lista `skills:` (`./feature-planner` → `./replit-style-workflow`), keywords (+`replit-style`).
- **`marketplace.json`** root → `v1.3.0`: opis dev-tools odzwierciedla nową nazwę + pozycjonowanie.
- **`README.md`** (root), **`dev/README.md`**, **`AGENTS.md`** — wszystkie wzmianki o `feature-planner` (jako skill v2) zaktualizowane do `replit-style-workflow` z notą historyczną. Decision tree i tabela pluginu zsynchronizowane.
- **`dev/audited-feature-workflow/SKILL.md`** — `extends: feature-planner-v2` → `extends: replit-style-workflow` + link w indeksie referencji zsynchronizowany.
- **`dev/audited-feature-workflow/README.md`** + **`dev/audited-feature-workflow/CHANGELOG.md`** (preambuła) + **`dev/audited-feature-workflow/references/testing-map.md`** (Anti-Rat wiersz) — wzmianki o "v2" zsynchronizowane.
- **`pzp/odpowiedzi-pytania/SKILL.md`** — usunięte stale ref do `feature-planner` (wzmianka „przygotuj SWZ" — to skill PZP, nie dev/, więc reference był błędny od dawna; po renamie skill author'a wzmianka byłaby podwójnie myląca).

### Why

Nazwa `feature-planner` sugerowała wyłącznie planowanie — myliło się z [`feature-spec-planner`](dev/feature-spec-planner/) który JEST planning-only. Skill robi pełny workflow (plan → impl → 7 test scopes → preview → review → ADR) w "Replit Agent style". Nowa nazwa odzwierciedla unikalną wartość: auto-routing (6-Sequential / 6-Teams / 6-Ralph) + deep research + worktree decision + 7 test scopes. Frontmatter `name: feature-planner-v2` vs folder `feature-planner` był też inkonsystencją od początku — teraz oba zsynchronizowane.

### Co NIE zmienia się

- **Funkcjonalność skilla** — pure rename refactor, zero zmian w SKILL.md content czy references.
- **Trigger keywords** — `"dodaj feature v2"`, `"zaimplementuj"`, `"implement"`, `"build feature"`, `"ralph"`, etc. zachowane (router description-driven).
- **22/22 testów `agent-teams-builder/tests/run-meta-tests.sh`** — regresja sprawdzona po wszystkich zmianach.

### Migracja

Wywoływanie przez trigger phrasy → bez zmian. Wywoływanie przez `name:` bezpośrednio → użyj `replit-style-workflow` (nie `feature-planner-v2`).

## [2026-05-25] dev — Test Discipline (3 skille: a-t-b v1.9.0 + v3 v3.2.0 + v2 v2.2.0)

### Added

- **`dev/agent-teams-builder/references/testing-map.md`** (v1.9.0) — mapa meta-testów walidatorów: 19 walidatorów × status (10/19 unit ✅, 3/19 integration ✅, 9 TODO) + 22/22 cases w runnerze + procedura Prove-It dla regresji. Status pokrycia surowo z `bash tests/run-meta-tests.sh`.
- **`dev/audited-feature-workflow/references/testing-map.md`** (v3.2.0) — mapa meta-testów skryptów v3 (0/7 obecnie pokryte, plan retrofitting). Rozróżnia 2 piętra: `testing-protocol.md` (testy aplikacji wytwarzanej) vs `testing-map.md` (meta-testy samego skilla). Wykryto martwe fixtures `complete-plan.md`/`incomplete-plan.md` w v3 — żaden skrypt v3 ich nie wywołuje.
- **`dev/feature-planner/references/testing-map.md`** (v2.2.0) — Test Discipline dla v2 (prose-heavy, 0 walidatorów). Wymusza pryncypium retrofittingu: każda nowa funkcjonalność v2 = nowy walidator + fixture + assert_exit.
- **SKILL.md w 3 skillach** — 1-3 wiersze Anti-Rationalization (specyficzne dla meta-testów: trywialny walidator/bug bez regresji/integration zbędny), 1 checkbox DoD (Beyoncé Rule dla samego skilla), 1 wpis w indeksie referencji z regułą ładowania.

### Removed / Changed

- (brak removalu — wszystkie istniejące fixtures/runnery zachowane; szczególnie `dev/agent-teams-builder/tests/run-meta-tests.sh` przechodzi nadal **22/22 passed** po edycjach SKILL.md)

### Why

User pytał czy 3 skille (a-t-b, v2, v3) mają testy unit/integration/regression. Stan na 2026-05-25: a-t-b ma 22/22 testów ale brak mapy → reszta nie była audytowalna. v3 ma 7 skryptów z 0 meta-testami + 2 martwe fixtures (artefakt po refaktorze z v3 do feature-spec-planner). v2 jest prose-heavy bez żadnej infrastruktury. Pytanie obnażyło lukę: brak **dokumentu mapującego funkcjonalność → typ testu**. User instrukcja: „jak coś wytwarzasz to tworzysz testy" + „skorzystaj z DOC". Implementacja: 3 × `testing-map.md` zakorzenione w DOC (`material_skill.md §4,§5` + `since_skill.md §5` + `INSTRUKCJA §9,§10`) + minimalne hooki w SKILL.md (Anti-Rat + DoD + reguła ładowania).

### Test Coverage (surowy snapshot)

```
$ bash dev/agent-teams-builder/tests/run-meta-tests.sh | tail -3
========================================
  RESULT: 22/22 passed, 0 failed
========================================
```

| Skill | Wersja | Unit | Integration | Regression | Runner |
|---|---|---|---|---|---|
| agent-teams-builder | v1.9.0 | 10/19 ✅ | 3/19 ✅ | 0 (brak historycznych bugów) | ✅ tests/run-meta-tests.sh (345 linii, 22/22 passed) |
| audited-feature-workflow | v3.2.0 | 0/7 ❌ | 0 ❌ | 0 ❌ | ❌ TODO retrofit (priorytet #1 wg testing-map.md) |
| feature-planner (v2) | v2.2.0 | 0 ❌ (brak scripts/) | 0 ❌ | 0 ❌ | ❌ Pryncypium retrofittingu: każda nowa funkcjonalność = nowy walidator |

### Sources

DOC (lokalne, gitignored): `DOC/material_skill.md §4 (DoD = dowód), §5 (Beyoncé Rule, DAMP, piramida 80/15/5)` + `DOC/since_skill.md §5 (TDD RED-GREEN-REFACTOR + Prove-It Pattern = test regresji)` + `DOC/INSTRUKCJA-BUDOWANIA-SKILLI.md §9 (Checklist gotowości — Beyoncé), §10 (source: traceability w references/)`.

## [2026-05-25] dev/feature-planner-codex — usunięcie skilla

### Removed

- **`dev/feature-planner-codex/`** — cały skill (8 plików: SKILL.md, CHANGELOG.md, agents/openai.yaml, references/{ac-protocol,adr-template,analysis-protocol,code-review-protocol,testing-protocol}.md). Wariant codex-native (OpenAI Codex CLI) wycofany — repo koncentruje się wyłącznie na Claude Code (3 warianty plannerów: feature-planner v2 · audited-feature-workflow · feature-spec-planner).

### Changed

- **`dev-tools`** (plugin) → `v1.2.0`: usunięto `feature-planner-codex` z `skills:` (6 skilli). `description` i `keywords` zaktualizowane (`codex` usunięte z keywords). [`dev/.claude-plugin/plugin.json`](dev/.claude-plugin/plugin.json).
- **`marketplace.json`** (root) → `v1.2.0`: opis `dev-tools` zsynchronizowany z nową listą skilli.
- **`README.md`** (root) — usunięty wiersz tabeli i bullet „Praca w Codex CLI"; tabela „Instalacja" zaktualizowana (`dev-tools` 6 skilli, z swarm-orchestrator zamiast feature-planner-codex); „cztery warianty" → „trzy warianty".
- **`dev/README.md`** — usunięty wiersz tabeli planerów, gałąź decision tree „Środowisko = Codex CLI", sekcja trigger keywords „### feature-planner-codex"; „Cztery warianty" → „Trzy warianty".
- **`AGENTS.md`** — usunięty wpis pozycjonowania `feature-planner-codex (Codex CLI)`.

## [2026-05-24] dev/swarm-orchestrator v1.0.0 — multi-agent tmux orchestration z YOLO/goal

### Added

- **`dev/swarm-orchestrator/`** — nowy skill: orkiestracja 4 agentów Claude Code w tmux -CC panes (parent / planner / generator / evaluator) z 3 trybami (manual / hybrid default / yolo). Komponuje widzialność tmux z [`DOC/agents_swarm/`](DOC/agents_swarm/) (prototyp local-only), rygor 5 bramek + kontrakty + breadcrumbs z [`dev/agent-teams-builder/`](dev/agent-teams-builder/) i autonomię `/goal` z [`dev/audited-feature-workflow/`](dev/audited-feature-workflow/) (Phase 6-Goal route).
- SKILL.md (268 linii, limit 500) z 8 fazami + 5 bramkami + Anti-Rat 8 wierszy + DoD 12 punktów + frontmatter kanoniczny (`trigger`, `do-not-trigger-for`, `model`, `allowed-tools`, `sources`, `version`, `size-limit`).
- 10× `references/*.md`: modes-protocol, tmux-orchestration, goal-mode-integration, stop-conditions, approval-gates-protocol, pivot-protocol, recovery-protocol, anti-rationalization (pełna tabela 18 wymówek), hook-integration, prd-input-schema.
- 26 skryptów `scripts/`: lib/ (paths/state/prompt/tmux) + swarm-* entry-points + walidatory/checki + **NOWE** `swarm-yolo.sh` (single-iteration driver z 7 STOP conditions + atomic commit guard + auto-pivot), `error-hash.sh` (md5 sygnatury błędu dla no-progress detection), `archive-run.sh` (tar.gz + delete po gate:5).
- 4 agenty `agents/swarm-{parent,planner,generator,evaluator}.md` (1:1 z prototypu DOC/agents_swarm).
- 10 promptów `prompts/`: 4 boot + 5 phase + **NOWY** phase-yolo-iterate.md (generator iteracja w YOLO).
- Assets: plan-template.md, contract-template.json, breadcrumbs-schema.json.
- Tests: 5 fixtures (good/bad PRD) + `run-meta-tests.sh` (47 checków: syntax/fixtures/structure/scripts-exec/error-hash). **47/47 passed.**

### Decyzje produktowe (potwierdzone z user)

- Backend domyślny: **tmux panes** (4 procesy `claude`); Task tool fallback gdy brak tmux.
- Tryb domyślny: **hybrid** (5 bramek HITL + auto między).
- YOLO: **single sprint** per invokacja, **atomic commits** bez `git push`, **auto-pivot** po 3× no-progress.
- State retention: **auto-archive po sukcesie** (gate:5) → `.agents-swarm/archives/{RUN_ID}.tar.gz`; failed runs zostają do debugu.

### Twarde zakazy YOLO (egzekwowane przez `swarm-yolo.sh`)

- `git push`, `npm publish`, `gh pr create`, `gh release`, `DROP`, `rm` poza `paths_in_scope` — zawsze human gate.
- Fragile zones (`migrations/`, `terraform/`, `k8s/`, `auth/`, `.github/workflows/`, `Dockerfile`, `prod*`) — exit 5 chyba że `--force-fragile` (logowane w breadcrumb `fragile_override`).

### Changed

- **`dev-tools`** (plugin) → `v1.1.0`: dodano `swarm-orchestrator` (7 skilli). Zaktualizowano `dev/.claude-plugin/plugin.json` (skills array, version, +4 keywords: tmux/swarm/yolo/goal-mode), `marketplace.json` description (root version 1.0.0 → 1.1.0).

## [2026-05-22] legal/sejm-eli-api v1.0.0 — komunikacja z Sejm ELI API

### Added

- **`legal/sejm-eli-api/`** — nowy skill: warstwa retrieval/grounding dla urzędowego źródła prawa RP przez `api.sejm.gov.pl/eli`. SKILL.md (187 linii) z procedurą 6-fazową + exit criteria, Anti-Rationalization (7 wymówek), DoD, frontmatterem kanonicznym (`trigger`, `do-not-trigger-for`, `sources`, `version`, `size-limit`).
- `references/endpoints.md` — katalog endpointów zweryfikowany `curl`-em 2026-05-22 (`/acts`, `/acts/{pub}/{year}[/{pos}]`, `…/text.html|text.pdf|struct|references`, `/acts/search` z paginacją).
- `references/obsidian-import.md` — format notatki + opcje importera.
- `scripts/eli-fetch.sh` (POSIX, `set -eu`) + `scripts/import-eli-act.py` (vault z `--vault`/`OBSIDIAN_VAULT`, bez ścieżek absolutnych). Oba przetestowane na żywym API (meta/search/import + guardy).
- Pozycjonowanie: warstwa pozyskania metadanych; interpretacja → `legal/opinie-prawne`.

### Changed

- **`legal-tools`** (plugin) → `v1.1.0`: dodano `sejm-eli-api` (2 skille). Zaktualizowano `marketplace.json`, `legal/.claude-plugin/plugin.json`, README (tabela legal + tabela marketplace).

## [2026-05-22] Plugin marketplace — repo jako źródło instalowalne w Claude Code

### Added

- **`.claude-plugin/marketplace.json`** (root) — manifest marketplace `kgpsp-skills` z 3 pluginami wg domen: `pzp-tools`, `legal-tools`, `dev-tools`.
- **`pzp/.claude-plugin/plugin.json`** — plugin `pzp-tools` (4 skille: analyzing-pzp-offers, drafting-pzp-letters, odpowiedzi-pytania, weryfikacja-umow-pzp).
- **`legal/.claude-plugin/plugin.json`** — plugin `legal-tools` (1 skill: opinie-prawne).
- **`dev/.claude-plugin/plugin.json`** — plugin `dev-tools` (6 skilli: agent-teams-builder, feature-planner-v2, audited-feature-workflow, feature-planner-v2-codex, feature-spec-planner, playwright-test-suite).
- Pole `skills:` w każdym `plugin.json` wskazuje istniejące katalogi skilli wprost (bez przenoszenia plików) — `skills` jest additywne do domyślnego `skills/`. Instalacja: `/plugin marketplace add KGPSP/skills` → `/plugin install <plugin>@kgpsp-skills`. Zwalidowane `claude plugin validate .` (passed).

## [2026-05-22] weryfikacja-umow-pzp v1.1.0 — domknięcie zgodności z DOC

### Fixed

- **`pzp/weryfikacja-umow-pzp/`** — najpoważniejsze naruszenie z całej domeny PZP: **SKILL.md 703 → 480 linii** (twardy limit ≤500). Ciężkie bloki wyniesione do `references/` (`sed`, bajt-w-bajt): `legal-basis-catalog.md` (art. 431–465 + k.c./RODO/KSC/pr.aut.), `edge-cases.md` (18 + Common Mistakes), `format-obsidian.md`, `kg-psp-integration.md`.
- **Ścieżka absolutna `/Users/mklosinski/…`** → `{prawo_dir}`.

### Changed

- **Frontmatter kanoniczny:** `trigger:`, `do-not-trigger-for:` (§7), `model:`, `allowed-tools:` (bez `Edit`), `sources:` (→ DOC), `size-limit:`.
- **Filar 1** — skonsolidowana tabela **exit criteria** faza→artefakt + `TodoWrite`.
- **Filar 2** — Red Flags → tabela **Anti-Rationalization** (9 wymówek).
- **Filar 3** — Deliverables Checklist oznaczona jako **Definition of Done**.
- **Filar 4** — `verification-prompt.md` → `references/` (`git mv`, §1/§10); Supporting Files → tabela **reguł ładowania L3 imperatywnych** (§5); **frontmatter referencji** w 5 plikach `references/` (§10).
- Bez zmian merytorycznych (katalog art. 431–465, 18 edge cases, P1–P7/R1–R4, Iron Law — przeniesione 1:1 do `references/`). SKILL.md 480 linii (≤500).

## [2026-05-22] odpowiedzi-pytania v1.1.0 — domknięcie zgodności z DOC

### Fixed

- **`pzp/odpowiedzi-pytania/`** — trzy bugi przy okazji audytu DOC:
  - latent bug YAML: `description` miał `… \`odpowiedzi_<RRRR-MM-DD>/\`: indeks…` (dwukropek+spacja → rozsypywał frontmatter po dodaniu pól). Zamienione na `—`.
  - ścieżki absolutne `/Users/sq13pl/…` w referencjach (`prawo-index.md`, `pzp-articles-map.md`) → `{prawo_dir}` (§4).
  - over-exclusion w `do-not-trigger-for` („istotna zmiana charakteru" — wykrywane w Phase 4.5, nie pre-aktywacyjnie) usunięte; body „When NOT to Use" zsynchronizowane.

### Changed

- **Frontmatter kanoniczny:** `trigger:`, `do-not-trigger-for:` (§7), `model:`, `allowed-tools:` (`Bash`/`Read`/`Write`/`Glob`/`Grep`/`TodoWrite`, bez `Edit`), `sources:` (→ DOC), `size-limit:`.
- **Filar 1** — skonsolidowana tabela **exit criteria** faza→artefakt + nakaz `TodoWrite`.
- **Filar 2** — Red Flags → kanoniczna tabela **Anti-Rationalization** (9 wymówek).
- **Filar 3** — Phase 7 oznaczona jako **Definition of Done**.
- **Filar 4** — Supporting Files → tabela **reguł ładowania L3 imperatywnych** (§5); **frontmatter referencji** w 4 plikach `references/` (§10) — struktura `references/` była poprawna od początku.
- SKILL.md 483 linie (≤500; miejsce na frontmatter odzyskane kompresją duplikatów — pełna mapa artykułów w `references/pzp-articles-map.md`). Bez zmian merytorycznych (Phase 4.5 STOP-gate, reguły terminowe art. 135/137/284/286, 11 reguł bezwzględnych, Iron Law).

## [2026-05-21] drafting-pzp-letters v1.1.0 — domknięcie zgodności z DOC

### Fixed

- **`pzp/drafting-pzp-letters/`** — dwa bugi przy okazji audytu DOC:
  - **Ścieżka absolutna** w Phase 4 (`/Users/mklosinski/…/wzor_pismo_przewodnie.docx`, cudze konto) → parametr `<template_docx>` w Required Inputs.
  - **Niepoprawny YAML** `description` (`Triggers include:` → `Triggers include —`); frontmatter teraz parsuje się czysto.
  - Exec-bit `scripts/render_docx.py` `100644` → `100755`.

### Changed

- **Frontmatter kanoniczny:** `trigger:`, `do-not-trigger-for:` (§7), `model:`, `allowed-tools:` (`Bash`/`Read`/`Write`/`Glob`/`Grep`/`TodoWrite`, bez `Edit` na kodzie), `sources:` (→ DOC), `size-limit:`.
- **Filar 1** — exit criteria po fazach 0–5 + nakaz `TodoWrite`.
- **Filar 2** — Red Flags → kanoniczna tabela **Anti-Rationalization** (`Wymówka | Riposta`, 10 wymówek).
- **Filar 3** — dodana **Definition of Done** (checklista pakietu pism).
- **Filar 4** — heavy references przeniesione do **`references/`** (`git mv`, §1/§10); Supporting Files → tabela **reguł ładowania L3 imperatywnych** (§5) + jawne ładowanie w Phase 2; **frontmatter referencji** w obu plikach (§10).
- Bez zmian merytorycznych (tabela decyzyjna F→pismo, reguły grupowania/eskalacji, self-cleaning, Iron Law). SKILL.md 398 linii (≤500).

## [2026-05-21] analyzing-pzp-offers v1.1.0 — domknięcie zgodności z DOC

### Changed

- **`pzp/analyzing-pzp-offers/`** — audyt względem `DOC/` i naprawa formalnych niezgodności (bez zmian merytorycznych: 18 edge cases, podstawy prawne Pzp/KSC, Iron Law nietknięte).
  - **Frontmatter kanoniczny:** dodane `trigger:`, **`do-not-trigger-for:`** (§7, z „When NOT to Use"), `model:`, `allowed-tools:` (`Bash`/`Read`/`Write`/`Glob`/`Grep`/`TodoWrite`, bez `Edit` na kodzie), `sources:` (→ DOC), `size-limit:`.
  - **Filar 1** — **exit criteria** po fazach 0–5 + nakaz `TodoWrite`.
  - **Filar 2** — Red Flags → kanoniczna tabela **Anti-Rationalization** (`Wymówka | Riposta`, 9 wymówek domenowych).
  - **Filar 3** — „Deliverables Checklist" oznaczona jako **Definition of Done**.
  - **Filar 4** — Supporting Files → tabela **reguł ładowania L3**; heavy reference przeniesiony do **`references/`** (`git mv`, §1/§10): `references/verification-prompt.md` (odwołania w SKILL.md + templatach zaktualizowane); **frontmatter referencji** (`type: reference`, `parent`, `sources:` → §DOC).
  - Body „When NOT to Use" zsynchronizowane z `do-not-trigger-for`. SKILL.md 499 linii (limit ≤500, margines 1 linia → konsolidacja „Common Mistakes" zaplanowana na v1.2.0).

## [2026-05-21] opinie-prawne v1.1.0 — domknięcie zgodności z DOC

### Changed

- **`legal/opinie-prawne/`** — audyt względem `DOC/` i naprawa formalnych niezgodności (bez zmian merytorycznych w metodzie prawnej).
  - **Frontmatter kanoniczny:** dodane `trigger:`, **`do-not-trigger-for:`** (brakujące Negative Triggers — §7), `model:`, `allowed-tools:` (research+analiza, bez `Edit`/`Bash` na kodzie), `sources:` (→ DOC), `size-limit: 500-lines-hard`.
  - **Filar 2** — kanoniczna tabela **Anti-Rationalization** (`Wymówka | Riposta`, 8 wymówek domenowych) obok istniejących Red flags i Zakazów.
  - **Filar 1** — **exit criteria** po każdym z 9 kroków metody + checklista **Definition of Done** (8 pozycji).
  - **Filar 4** — jawne **reguły ładowania L3** (tabela „załaduj gdy") + **frontmatter referencji** (`type: reference`, `parent`, `sources:` → sekcje DOC z numerem §) w obu plikach `references/` (§10).
  - SKILL.md 464 linie (limit ≤500).

## [2026-05-21] feature-spec-planner v1.0.0 — planning-only wariant audited-feature-workflow

### Added

- **`dev/feature-spec-planner/`** — skill planowania, analizy i dokumentacji feature'a **bez fazy implementacji**. Pochodny od `audited-feature-workflow` (fazy 0–5 + ADR), odcina fazy wykonawcze.
  - **SKILL.md** (256 linii, limit ≤500) — **7 faz + 1 bramka akceptacji** (Phase 6): env-detection → deep analysis (Hyrum+Chesterton) → impact radius → ≥3 hipotezy → recommendation → plan (AC matrix + DoD-spec + Thin Slices + Out-of-scope + Rollback) → ADR → handoff.
  - **8 referencji** — `non-negotiables` i `anti-rationalization` przepisane w wersji planistycznej; `analysis-protocol`, `ac-protocol` (+ DAMP + piramida 80/15/5), `dod-evidence-protocol`, `incremental-implementation`, `adr-template`, `gotchas` zaadaptowane (numery faz przemapowane na model feature-spec-planner).
  - **2 skrypty** — `api-impact-scan.sh` (Hyrum, z v3) + nowy `check-plan-complete.sh` (bramka kompletności pakietu) + 2 fixtures (gate exit 0 / exit 1).

### Pryncypia (audit DOC)

- **material_skill.md + since_skill.md**: 21/21 pryncypiów obecnych. AC↔Test (Beyoncé), DoD i raw-evidence egzekwowane jako **specyfikacja** (feature-spec-planner nie wykonuje); reguły czysto wykonawcze (TDD RED, build clean, Five-Axis, Prove-It) jawnie przekazane wykonawcy.

### Pozycjonowanie

- **feature-spec-planner** — wytwarza audytowalny pakiet planistyczny (analiza + plan + ADR), kończy na zatwierdzonym planie.
- **audited-feature-workflow** — od Phase 6 realizuje plan (implementacja + testy + review). Komplementarne: feature-spec-planner planuje, v3 buduje.

---

## [2026-05-20] Documentation Protocol — agent-teams-builder v1.6.0 + playwright-test-suite v1.2.0

### Added

Pełen audit trail wszystkich dokumentów pracy zespołu agentów. **10 typów dokumentów** w dwóch warstwach:

**Ephemeral (state/):**
- PRD per sprint, TODO snapshot, retrospectives, sessions log, decision log, QA reports, final report

**Committable (docs/):**
- ADRs sekwencyjne (`ADR-{NNNN}-{slug}.md`)
- Five-Axis Code Reviews per sprint passed
- Final reports (kopia z state/)

### Nowe komponenty

- `references/documentation-protocol.md` — pełen protokół (10 typów × kto/kiedy/format)
- 5 templates: PRD, ADR, retrospective, code review (Five-Axis), session log
- 3 skrypty: `init-docs-structure.sh`, `verify-documentation.sh`, `append-session-log.sh`
- Group 8 meta-tests (19/19 passed)

### Why

User chce **wiedzieć co dzieje**. Po v1.6: każda decyzja udokumentowana (ADR), każdy sprint ma retrospektywę + code review, ślad audytu kompletny. Po sesji `/goal` można prześledzić KAŻDĄ decyzję bez surowych breadcrumbs.

---

## [2026-05-20] Planning Rigor (transfer z audited-feature-workflow) — agent-teams-builder v1.5.0

### Added

- **Planning Rigor protocol** — `agent-teams-builder` dziedziczy dyscyplinę planistyczną z `audited-feature-workflow`:
  - **3 hipotezy per sprint** (Minimal/Idiomatic/Ambitious) z trade-offs, Hyrum risk, kosztem.
  - **11 obowiązkowych sekcji planu** (z 6 do 11): Goal, Sprints (z hipotezami), Dependencies, Open Questions, Out of scope, Success metric, Risks (skalowane H/M/L), **Recommendation summary** (nowa), **Hyrum Impact** (nowa), **Rollback plan** (nowa), **Alternatives considered** (nowa).
  - **AC priorities** MUST/SHOULD/COULD (przejęte z `ac-protocol.md`).
  - **Walidator** `verify-plan-rigor.sh` egzekwujący strukturę.

### Why

Planner v1.4 produkował płaską listę sprintów bez audytu wyborów architektonicznych. Po transferze rygoru z audited-feature-workflow — każda decyzja jest udokumentowana, alternatywy odrzucone explicite, Hyrum Impact wykrywany PRZED implementacją (nie po regresji).

### Test results

- `bash dev/agent-teams-builder/tests/run-meta-tests.sh` → **16/16 passed** (z 14 → 16).

---

## [2026-05-20] context7 MCP integration — agent-teams-builder v1.4.0 + playwright-test-suite v1.1.0

### Added

- **Library Currency Protocol** — wszystkie 4 sub-agenty (planner/generator/evaluator/playwright-runner) OBOWIĄZKOWO wywołują **context7 MCP** przed każdym nowym importem lub setupie biblioteki. Eliminuje halucynacje API (pierwsza przyczyna zerwanej pętli generator-ewaluator).
- **4-poziomowy fallback chain**: context7 → DeepWiki MCP → WebFetch → `npm view` + JSDoc (offline).
- **`scripts/setup-context7.sh`** — idempotentny instalator MCP (per-user `claude mcp add` LUB per-project `.mcp.json`).
- **`scripts/verify-library-currency.sh`** — walidator: każdy sprint dotykający `package.json`/`Cargo.toml`/`requirements.txt`/`go.mod` MUSI mieć breadcrumb `library_currency_checked` z prawidłowym `source`.
- **`references/library-currency-protocol.md`** + **`assets/mcp-config-template.json`** + **`assets/claude-md-template.md`** (auto-invoke regułą).
- **3 nowe meta-testy** w `run-meta-tests.sh` (14/14 passed).

### Why

Halucynacja API (LLM cutoff date) była pierwszą przyczyną patologicznej pętli: Generator pisze przeterminowany kod → Evaluator widzi runtime error → kolejne iteracje z kolejnymi halucynacjami → pivot. Context7 dostarcza aktualną, version-specific dokumentację bibliotek bezpośrednio do kontekstu agenta.

---

## [2026-05-20] audit(dev): Google DNA compliance — agent-teams-builder v1.3.0 + playwright-test-suite v1.0.1

Audit pryncypiów wg `material_skill.md` §5 (Google DNA) + §8 (5 Non-negotiables) + `since_skill.md` §2 (5 filarów) wykrył luki w pokryciu 4 zasad inżynieryjnych Google. Naprawione w obu skillach.

### Changed

- **`dev/agent-teams-builder/`** → **v1.3.0**
  - `SKILL.md` — 4 nowe wymówki anty-racjonalizacyjne (Chesterton's Fence / Hyrum's Law / Beyoncé Rule / DAMP > DRY).
  - `references/anti-rationalization.md §5` — nowa sekcja "Google DNA" z 6 wymówkami i ripostami (przed: **brak Chesterton's Fence**).
- **`dev/playwright-test-suite/`** → **v1.0.1**
  - `SKILL.md` — nowa sekcja "Google DNA" + 4 nowe wymówki + DoD rozszerzony o Beyoncé/DAMP/Chesterton checks + explicit `(Non-negotiable #N)` labels + token budget L2 ≤5000.
  - `references/playwright-ui-protocol.md §5` — nowa sekcja "Google DNA w testach" z przykładami ✅/❌.

### Audit summary (po fixach)

| Zasada | agent-teams-builder | playwright-test-suite |
|---|---|---|
| Hyrum's Law | 8+ wzmianek ✅ | (w obu) ✅ |
| Chesterton's Fence | 5+ (było **0**) ✅ | ✅ |
| Beyoncé Rule | 15+ ✅ | 6+ ✅ |
| DAMP > DRY | 5+ ✅ | 7+ ✅ |

### Sanity tests

- `agent-teams-builder/tests/run-meta-tests.sh` → **11/11 passed** ✅
- `verify-role-isolation.sh` z 4 sub-agentami → ✅

---

## [2026-05-20] playwright-test-suite v1.0.0 + agent-teams-builder integration

### Added

- **`dev/playwright-test-suite/`** — dedykowany skill QA dla aplikacji webowych. 5-fazowa procedura (smoke → UI → DevTools → a11y → visual) przez Playwright CLI + `@axe-core/playwright` + pixelmatch. Pełna struktura:
  - SKILL.md (~250 linii)
  - **agents/playwright-runner.md** — dedykowany sub-agent Claude Code
  - references/ (7 protokołów)
  - scripts/ (7 orchestratorów)
  - templates/ (7 Playwright .ts.tmpl)

### Changed

- **`dev/agent-teams-builder/agents/evaluator.md`** — sekcja "Delegacja do playwright-runner" z gotowym wzorcem `Task(subagent_type: "playwright-runner")`. Evaluator deleguje pełne QA do dedykowanego sub-agenta zamiast wywoływać Playwright/Chrome inline.
- **`dev/agent-teams-builder/scripts/verify-role-isolation.sh`** — uznaje `playwright-runner` jako allowed producer evidence files + dodaje walidację jego izolacji (read-only na kodzie).

### Architecture (po tym sprincie)

```
parent agent (główne okno)
   ├── Task(planner)    → state/plan.md
   ├── Task(generator)  → kod w src/
   └── Task(evaluator)  → werdykt
              └── Task(playwright-runner)  ← NOWY skill
                     ├── 5 faz QA
                     └── state/evidence/sprint-{n}/qa-summary.json
```

---

## [2026-05-20] agent-teams-builder v1.2.0 — meta-tests

### Added

- **`dev/agent-teams-builder/tests/`** — 7 fixtures testowych (GOOD/BAD przykłady dla każdego walidatora) + `run-meta-tests.sh` (11 testów w 5 grupach, sprawdza że walidatory zachowują się zgodnie z oczekiwaniem).

### Fixed

- `scripts/check-breadcrumbs-append-only.sh` — bug `set -e -o pipefail` aborts skrypt gdy `grep` nie znajduje matchu w pipe. Naprawione przez lokalne `set +o pipefail`.

### Test results

- `bash tests/run-meta-tests.sh` → **11/11 passed**.

---

## [2026-05-20] agent-teams-builder v1.1.0

### Added

- **`dev/agent-teams-builder/`** — orkiestracja zespołu sub-agentów (Planner + Generator + Evaluator + opcjonalni specjaliści) wg wzorca Generator-Ewaluator do realizacji złożonych zadań programistycznych.
  - **SKILL.md** (~270 linii, limit ≤500) — 7-fazowa procedura (bootstrap → ship) z exit criteria per faza.
  - **`agents/`** (3 pliki) — gotowe definicje sub-agentów Claude Code (`planner.md`, `generator.md`, `evaluator.md`) z izolowanymi tools (Generator BEZ Playwright, Evaluator BEZ Edit).
  - **`references/`** (10 protokołów, ~2200 linii) — progresywne ładowanie: `contract-negotiation`, `evaluator-rubric`, `pivot-protocol`, `memory-filesystem`, `role-mapping`, `goal-mode-protocol`, `anti-rationalization`, `non-negotiables`, `dod-evidence-protocol`, `traces-reading`.
  - **`scripts/`** (12 skryptów bash, ~1000 linii) — `init-team-state`, `append-breadcrumb`, `check-contract-coverage`, `verify-evaluator-rubric`, `pivot-trigger`, `smoke-test-runner`, `check-breadcrumbs-append-only`, `verify-role-isolation`, `check-evidence-completeness`, `run-goal-loop`, `check-scope-discipline`, `verify-non-negotiables`.
  - **`assets/`** (6 plików) — szablon kontraktu z 15 binarnymi kryteriami, few-shot rubryki "good design vs AI slop", JSON schemy dla feature_list i breadcrumbs, plan template, prompt-templates.
  - **Tryb `/goal`** — autonomiczna pętla AC z auto-pivotem po MAX_ITERATIONS.
  - **Mechanizm pivota** — Plan-Validate-Execute dla operacji destruktywnych, archiwizacja branchu przed `rm -rf`, opcjonalny human hook (`PIVOT_REQUIRES_HUMAN=1`).

### Source

- `DOC/agent-teams-generator-ewaluator.md` (wzorzec Generator-Ewaluator, sekcje 1-10)
- `DOC/material_skill.md` §8 (5 Non-negotiables)
- `DOC/since_skill.md` §2 (5 filarów: Process / Anti-Rat / Verification / Progressive / Scope)
- `DOC/goal_mode.md` (przykłady `/goal` z mierzalną weryfikacją)

### Pozycjonowanie vs audited-feature-workflow

- **audited-feature-workflow** — pojedynczy feature, 1 sesja, 1 agent. Optymalny dla 100-300 linii diff.
- **agent-teams-builder** (ten skill) — projekty wielosprintowe, zespół sub-agentów z presją rywalizacyjną, dla pracy >2h. Optymalny dla "zbuduj aplikację od zera".

---

## [2026-05-12] audited-feature-workflow + dokumentacja repo

### Added

- **`dev/audited-feature-workflow/`** — nowy senior-grade skill (18 plików, 4200 linii):
  - SKILL.md (344 linii, hard limit ≤500)
  - 12 referencji (`anti-rationalization`, `non-negotiables`, `dod-evidence-protocol`, `fragile-operations-protocol`, `incremental-implementation`, `five-axis-review`, `gotchas` + 4 rozszerzone z v2 + `adr-template`)
  - 5 deterministycznych skryptów POSIX (`check-pr-size`, `verify-build-clean`, `check-ac-coverage`, `extract-raw-log`, `api-impact-scan`)
- **`dev/README.md`** — decision tree + porównanie v2 vs v3 + struktura plików v3
- **`pzp/README.md`** — indeks 4 skilli PZP z mapowaniem na fazy postępowania
- **`CHANGELOG.md`** — niniejszy plik
- **`.gitignore`** — wyłączenia (`DOC/`, macOS artefakty, IDE, `node_modules`, Python cache, secrets, tmp logs)

### Changed

- **`README.md`** (top-level) — dodano `audited-feature-workflow` do tabeli `dev/`, sekcja "Wybór dev/feature-planner (skrót)", sekcja "Pryncypia projektowania skilli (od v3)"

### Reżim koegzystencji

`feature-planner` (v2) i `audited-feature-workflow` koegzystują — żadnych zmian w plikach v2. Wybór świadomy przez trigger (`v3` w prompcie → v3, inaczej → v2).

---

## [Wcześniej]

Pojedyncze commity feature-by-feature na branchu `main`. Główne kamienie milowe (z git history):

- `0fd51c0` — feature-planner: TodoWrite usage + harden Ralph-loop
- `3efab06` — Add Ralph-loop autonomous workflow
- `7dcf821` — Add worktree decision (Phase 5.5) and live preview (Phase 7.8)
- `0bb6456` — Add 7-scope testing matrix and Playwright fallback
- `0ba33ae` — init: KGPSP skills catalog (pzp, legal, dev)

Pełna historia: `git log --oneline`.
