---
name: dynamic-workflows-standard
type: reference
parent: audited-feature-workflow
sources:
  - DOC/dynamic_workflows-cc.md
  - DOC/Messages_API_w_Opus_4.8.md
  - "https://code.claude.com/docs/en/workflows"
  - "https://code.claude.com/docs/en/model-config"
description: Standard wykorzystania Dynamic Workflows + mapowanie effort/ultrathink/ultracode (Opus 4.8) na poziomie orkiestracji w audited-feature-workflow. Ładuj warunkowo (Phase 0/1/6/8 dla M/L lub trigger workflow|ultracode; Phase 8 audyt na skalę).
---

# Dynamic Workflows — standard orkiestracji (Phase 0/1+)

> [!quote] Źródło (Claude Code v2.1.154+)
> „Orchestrate subagents at scale with dynamic workflows" — https://code.claude.com/docs/en/workflows
> Lokalny kanon: [DOC/dynamic_workflows-cc.md](../../../DOC/dynamic_workflows-cc.md) (§1–§14).

## 1. Czym są (potwierdzone z docs CC)

- **Dynamic Workflow** = skrypt JavaScript generowany przez Claude'a, wykonywany w tle przez runtime, orkiestrujący **dziesiątki–setki subagentów** (cap 16 concurrent, 1000 total/run).
- **Plan przenosi się z kontekstu do kodu** (zmienne runtime) → brak degradacji kontekstu, **wznawialność** (resume/checkpointing), adwersaryjna weryfikacja krzyżowa.
- Prymitywy: `agent()`, `parallel()` (bariera), `pipeline()` (bez bariery — domyślny), `phase()`, `log()`, `schema` (StructuredOutput), `budget`.

## 2. Effort & Thinking — mapowanie na mechanizmy CC

> **Kanon = `/effort`** (pewny, potwierdzony w docs CC/API). `ultrathink`/`ultracode` to affordances Claude Code **CLI zależne od wersji** — używaj z fallbackiem na `/effort`. NIE zakładaj dostępności komendy bez weryfikacji w swojej sesji.

| Mechanizm | Co robi | Jak włączyć | Status |
|---|---|---|---|
| **/effort** | poziom rozumowania `low`/`medium`/`high`/`xhigh`/`max` (`high` = domyślny) | `/effort <poziom>`, `effortLevel` w settings.json, `--effort`, env `CLAUDE_CODE_EFFORT_LEVEL` | **potwierdzony kanon** |
| **ultrathink** | maksymalny budżet rozumowania (`think` < `think hard` < `think harder` < `ultrathink`) | słowo `ultrathink` w prompcie (CLI) | keyword CLI (przywrócony ~v2.1.68); **nie API/web** → fallback `/effort max` |
| **ultracode** | `xhigh` effort + automatyczna orkiestracja workflows per zadanie | `/effort ultracode` (per-sesja; powrót `/effort high`) | opisany w DOC §5.3 i menu `/effort`; **dostępność zależna od wersji** → alias `/effort xhigh\|max` + orkiestracja |

> [!warning] Status terminów (uczciwość źródeł)
> `xhigh`/`max` wymagają wspieranego modelu (np. Opus 4.7/4.8). `ultrathink` nie działa w claude.ai/web ani bezpośrednio w API — to keyword Claude Code CLI. Dla `ultracode` dokładna składnia/dostępność **nie była weryfikowana zewnętrznie w tej sesji**; anchory URL pochodzą z researchu. Reguła Anti-Rationalization: nie wpisuj zmyślonej komendy jako jedynej ścieżki — zawsze podaj fallback `/effort`.

> [!note] Opus 4.8 — effort default (uczciwość źródeł)
> Opus 4.8 ustawia effort default = `high` na wszystkich oficjalnych powierzchniach, w tym Claude Code — **Messages_API §10 Aneks „Domyślny Poziom Wysiłku"**. Messages API **nie nazywa** poziomów `xhigh`/`max` na poziomie API; te pochodzą z `dynamic_workflows-cc.md §5.3` (poziomy `/effort` w CLI). Nie twierdź o API-level `xhigh`/`max`.

## 3. Standard dla tego skilla

- **Phase 1 (Deep Analysis) — DOMYŚLNIE max budżet rozumowania**: `/effort max` (kanon) + keyword `ultrathink` jeśli dostępny. Architecture walk + Hyrum + Chesterton wyznaczają sufit jakości w dół strumienia. Dla **S** (express-mode) dopuszcza zwykły effort.
- **M/L lub wieloskładnikowe → orkiestracja przez Dynamic Workflows.** Fan-out czytelników per podsystem (`parallel`/`pipeline`), synteza w jednym agencie. To **standard, nie opcja**, gdy analiza obejmuje wiele plików/warstw (reguła decyzyjna DOC §3: **>5 równoległych procesów badawczych** lub wolumen > okno kontekstu lub wymóg powtarzalności/audytu).
- **Opcjonalnie `/effort ultracode`** na całą sesję senior-grade — Claude sam decyduje o workflowach per faza (understand → implement → review).
- **Kiedy NIE workflow** (docs CC): praca w 1–2 turach; potrzebny mid-run user input; bardzo ograniczony budżet tokenów; zadanie to proste instrukcje (użyj zwykłych Agentów/edycji).

> [!danger] Workflows a bramki HITL — twarda reguła
> Workflows **NIE wspierają mid-run user input**. Bramki **APPROVAL #1–#5** oraz **/goal Gate #1.5** MUSZĄ pozostać POZA workflowem. Orkiestruj wyłącznie fazy bez-approvalowe (analiza, research, testy, review-findings); w bramkach wracaj do pętli głównej po jawną zgodę. **`/goal` jest wzajemnie wykluczający z Dynamic Workflows / `ultracode`** (Phase 5.8 hard stop). Workflow ≠ obejście HITL. W strefie `--fragile` workflows zakazane (Plan-Validate-Execute wymaga dosłownego wykonania). **Phase 6:** TDD-RED/build/PR-size per slice oraz **APPROVAL #2** zostają w synchronicznej pętli — Phase 6 NIE ma wożonego szablonu workflow (patrz §5a).

## 3a. Bramka deklaracji orkiestracji (enforced)

`scripts/check-orchestration-decl.sh` (Phase 1) egzekwuje **deklarację**, nie zachowanie — równie „mocna" jak `effort-level` (declare-not-prescribe). Dla **M/L** pole `orchestration:` w `analysis/<plan-id>.md` jest **wymagane** (`workflow|teams|sequential|none — <powód>`); **S** bez pola przechodzi. Reguły: skip `none` musi mieć uzasadnienie; `ultracode`/`ultrathink` musi podać fallback `/effort` (Anti-Rat); z `--goal` deklaracja `workflow`/`ultracode` → **exit 2** (self-consistency hard-stop — DW nie wspiera mid-run input z Gate #1.5). Gate **nie obserwuje**, czy workflow ruszył — to deklaracja + spójność, nie dowód behawioralny (jak flaga §5 „informacyjna").

## 4. Wzorce wykonawcze (z DOC/dynamic_workflows-cc.md)

- `pipeline()` domyślnie; `parallel()` tylko gdy potrzebny barrier (dedup / early-exit / cross-item).
- **Adwersaryjna weryfikacja**: N niezależnych sceptyków per znalezisko (Phase 1 Hyrum/Chesterton, Phase 8 Five-Axis) — wzmocnienie, nie zamiennik bramek.
- **Loop-until-dry** dla nieznanej liczby znalezisk; **completeness critic** na końcu.
- **Granulacja modeli** (DOC §11): tańszy model do parsowania, mocny do syntezy/review.
- `schema` (StructuredOutput) gdy agent zwraca dane do dalszego przetwarzania.

## 5. Integracja z fazami

| Faza | Użycie Dynamic Workflows |
|---|---|
| 0 | Detekcja size + trigger `workflow`/`ultracode` → flaga „orchestration" (informacyjna, poza gate 6/6). |
| 1 | `/effort xhigh\|max` + ultrathink; M/L → fan-out czytelników per podsystem + synteza (szablon `workflows/phase1-fanout-analysis.js`); deklaracja w `orchestration:`. |
| 6 | **Brak wożonego szablonu** — 6-Teams = natywna równoległość. Per-slice TDD-RED przed GREEN nie może być barierą HITL-free w fan-oucie; bramki + APPROVAL #2 POZA. |
| 8 | Five-Axis na skalę: agent per oś + adwersaryjna weryfikacja (szablon `workflows/phase8-five-axis-review.js`); wyklucza się z 6-Teams Phase 8. |

## 5a. Macierz wykluczeń (`/goal` × workflows × teams × `--fragile`)

Trzymana **bajt-spójnie** z `SKILL.md` (Phase 5.8) i blokiem `[!danger]` §3 — edycja jednego miejsca bez pozostałych przywraca niespójność, przed którą ta sekcja ostrzega.

| Kombinacja | Werdykt | Uzasadnienie (anchor) |
|---|---|---|
| `/goal` × `/teams` | **hard-stop** | konkurencyjne modele wykonawcze (SKILL.md Phase 5.8) |
| `/goal` × Dynamic Workflows / `ultracode` | **hard-stop** | DW bez mid-run input (Gate #1.5; DOC §9). Egzekwowane: `check-orchestration-decl.sh --goal` → **exit 2** |
| `/goal` × `--fragile` | **hard-stop** | Plan-Validate-Execute; autonomia niedozwolona |
| Dynamic Workflows / `ultracode` × `--fragile` | **zakazane** | PVE wymaga dosłownego wykonania |
| Dynamic Workflows × APPROVAL #1–#5 / Gate #1.5 | **bramka POZA** | brak mid-run input (DOC §9) |
| `ultracode` × prompty approval | **auto-skip** → APPROVAL **re-assert w pętli głównej** | DOC §6 (Auto: „Monity całkowicie pomijane w ultracode") — inaczej cichy bypass HITL |
| Workflow Phase 8 × 6-Teams Phase 8 | **wykluczające** | obie agent-per-oś; wybór po liczbie niezależnych osi |
| Phase 6 | **brak szablonu DW**; 6-Teams = równoległa, 6-Goal `/goal`-only | per-slice TDD-RED nie barierą HITL-free w fan-oucie |

Self-consistency bramki = deklaracja vs flagi `--goal`/`--fragile` (caller-supplied), **nie** obserwacja behawioralna. Reguły 6-Teams-vs-`/goal` i Phase-8-double-run pozostają prozowymi hard-stopami (nie do zamodelowania z `.md`) — uczciwe zawężenie, nie overclaim.

## 6. Limity (Chesterton dla racjonalizacji) — z DOC §9

Max **16 agentów równolegle**, max **1000 agentów/run**, brak interaktywności w locie, brak bezpośredniego IO skryptu wiodącego (delegacja do subagentów), **wyższy token usage** (liczy się do ratelimitów — sprawdź `/model` przed dużym runem). Subagenci **dziedziczą `acceptEdits` + allowlist** — operacje spoza allowlisty wstrzymują run na zgodę → ustaw allowlistę przed długim async runem (DOC §6). **Wznawialność związana z bieżącą sesją** — zamknięcie CLI czyści cache runtime (DOC §10).

## 7. Reguła ładowania (Progressive Disclosure)

Ładuj gdy: Phase 0 wykryła **size M/L** lub trigger `workflow`/`ultracode`; Phase 1 deep analysis; **Phase 6 routing** (Teams vs sequential); Phase 8 multi-axis review na skalę; ustawiasz reasoning budget. Dla **S/M synchronicznych** — pomiń.

## 8. Zapis workflow do reużycia + szablony skilla

- **Runtime save** (DOC §8): `/workflows` → `s` → **Local `.claude/workflows/`** (commitowane, widoczne dla zespołu po `git clone`) vs **Global `~/.claude/workflows/`** (per-maszyna, prywatne). Zapisany skrypt → natywny `/<nazwa>`; **Local wygrywa z Global** przy kolizji.
- **Szablony skilla** (`dev/audited-feature-workflow/workflows/*.js`, Phase 1 + Phase 8) to **wzorce referencyjne** wożone z pluginem (marketplace-safe; `../` poza katalog pluginu nie działa po instalacji) — **nie** runtime-save target. Walidowane `check-workflow-scripts.sh` (składnia + struktura, **nie** runnability: prymitywy wstrzykiwane przez runtime; `node --check` odrzuciłby top-level await/return/export, więc gate parsuje ciało opakowane w AsyncFunction — tak jak runtime).

## Sources

- [DOC/dynamic_workflows-cc.md](../../../DOC/dynamic_workflows-cc.md) — lokalny kanon (research-report, §1–§14).
- [DOC/Messages_API_w_Opus_4.8.md](../../../DOC/Messages_API_w_Opus_4.8.md) — Opus 4.8 Messages API (effort default high §10; model-exclusivity §9).
- https://code.claude.com/docs/en/workflows — Orchestrate subagents at scale.
- https://code.claude.com/docs/en/model-config — effort levels (low/medium/high/xhigh/max).
- Uwaga: anchory typu `#let-claude-decide-with-ultracode` pochodzą z researchu i nie były weryfikowane zewnętrznie w tej sesji.
