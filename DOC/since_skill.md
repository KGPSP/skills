---
title: "Architektura i wdrażanie Agent Skills: standardy inżynierii oprogramowania w epoce autonomicznych modeli generatywnych"
type: research-report
status: kanoniczny
version: v1
audience: liderzy techniczni, inżynierowie platformowi, architekci AI
tags: [agent-skills, ai-engineering, sdlc, claude-code, addy-osmani, google]
sources_count: 33
updated: 2026-05-27
---

# Architektura i wdrażanie Agent Skills

> **Typ:** research-report (pełny raport projektowy) · **Status:** kanoniczny · **Aktualizacja:** 2026-05-27
> **Rola w korpusie `DOC/`:** pełen raport (pięć filarów, SDLC, code review) — cytowany jako `source:` (§1–§8) przez ~45 plików skilli. Zwarta esencja → [`material_skill.md`](material_skill.md).

> [!abstract] TL;DR
> **Agent Skills** to opensource'owy framework (Addy Osmani, Google) wymuszający na agentach AI dyscyplinę seniora poprzez **deterministyczne procedury w plikach Markdown**. Repozytorium `addyosmani/agent-skills` (39K+ gwiazdek, licencja MIT) zawiera **22 ustrukturyzowane workflowy** mapujące cały SDLC. Pięć filarów (Process over Prose, Anti-rationalization Tables, Non-negotiable Verification, Progressive Disclosure, Scope Discipline) przekształca probabilistyczne LLM-y w przewidywalne narzędzia inżynieryjne.

---

**Słowa kluczowe:** Agent Skills · pięć filarów · Progressive Disclosure · token budget · Thin Vertical Slices · TDD · Prove-It · Five-Axis Review · Negative Triggers · kalibracja swobody.

## Spis treści

1. Ewolucja: od autouzupełniania do autonomii inżynieryjnej
2. Pięć fundamentalnych filarów
3. Mapowanie na SDLC: komendy slash jako bramki faz
4. Code Review & Quality: pięcioosiowy audyt
5. Incremental Implementation + TDD
6. Best practices dla twórców własnych skilli
7. Konsekwencje dla rynku pracy
8. Wnioski strategiczne
- Cytowane prace

---

## 1. Ewolucja: od autouzupełniania do autonomii inżynieryjnej

Narzędzia AI dla programistów przeszły radykalną ewolucję — od prostego autouzupełniania składni do **półautonomicznych agentów kognitywnych** (Claude Code, Cursor, Aider, Windsurf). Mimo postępów, agenci w domyślnej konfiguracji wykazują heurystyki *junior developera* [1].

**Domyślne patologie agenta AI:**

- Optymalizacja pod najkrótszą drogę do `task complete`, nie pod stabilność systemu [2].
- Ignorowanie kontekstu architektonicznego — rozwiązywanie problemu w izolacji, psucie sąsiednich integracji [4].
- Pomijanie testów, specyfikacji i analizy bezpieczeństwa.
- Brak instynktu samozachowawczego: refaktor *„przy okazji”* niszczy historię gita i czytelność PR-ów.

**Odpowiedzią jest Agent Skills** — framework Addy'ego Osmaniego (Engineering Director, Google Chrome), udostępniony na licencji MIT [3]. Repozytorium `agent-skills` to **22 ustrukturyzowane workflowy** (21 skilli SDLC + 1 meta-skill routera) [5], które przekształcają nieprzewidywalną kognicję w **deterministyczne drzewo umiejętności**.

---

## 2. Pięć fundamentalnych filarów

Framework odcina się od tradycyjnego prompt engineeringu (długie eseje w oknie kontekstowym) na rzecz pięciu nośnych decyzji projektowych.

### Filar 1: Process over Prose

Obszerne dokumentacje i podręczniki dobrych praktyk są nieefektywne w sterowaniu LLM-ami — ludzka abstrakcja nie ma przełożenia na atencję transformera [2].

> [!important] Reguła
> Każdy skill to **ustrukturyzowany algorytm workflow**: ponumerowane kroki, twarde punkty kontrolne, exit criteria. Agent nie może swobodnie zrezygnować — działa jak w procedurze operacyjnej systemu wysokiego ryzyka [6].

### Filar 2: Anti-Rationalization Tables

LLM-y rozwinęły silną tendencję do **lenistwa technologicznego** — racjonalizują pomijanie trudnych kroków w wewnętrznym chain of thought. Typowe wymówki [8]:

- *„Zmiana jest zbyt mała na specyfikację”*
- *„Szybko zaimplementuję bez planowania”*
- *„Istniejące testy pokrywają podobne przypadki”*
- *„Dodam testy regresyjne później”*

Każdy skill zawiera tabelę mapującą te wymówki na **miażdżące kontrargumenty** [6]:

| Wymówka agenta | Kontrargument |
|---|---|
| „Testy później” | „Później nigdy nie nadchodzi. TDD jest szybsze w skali projektu.” |
| „Pięć linii nie wymaga specyfikacji” | „Nawet 5 linii wymaga kryteriów akceptacji. Zero = dług.” |
| „Wydaje się działać” | „Bez dowodu (log/test/trace) zadanie nie istnieje.” |

Mechanizm radykalnie obniża odsetek pominiętych kroków QA [13].

### Filar 3: Non-negotiable Verification

Subiektywne *„wydaje się działać”* jest **definicyjnie odrzucane** jako fałszywe poczucie bezpieczeństwa [6]. Każdy skill kończy się żądaniem twardych dowodów:

- Pełny zrzut logów z passing testów.
- Czysty wynik linterów (warnings as errors).
- Build output bez ostrzeżeń.
- Runtime trace ze ścieżki krytycznej.

Brak artefaktów **blokuje zamknięcie wątku** [2].

### Filar 4: Progressive Disclosure

Okno kontekstowe to rzadki zasób. Załadowanie całej wiedzy na starcie powoduje *lost in the middle* — agent ignoruje najważniejsze instrukcje [15].

> [!tip] Architektura routera
> Plik nadrzędny `AGENTS.md` (lub meta-skill `using-agent-skills`) **stale rezyduje w kontekście** jako router. Analizuje intencję zadania i dynamicznie ładuje wyłącznie potrzebne pliki z podkatalogów (`references/api-errors.md` tylko przy błędach API, nigdy przy stylowaniu UI).

### Filar 5: Scope Discipline

LLM-y arbitralnie modyfikują niepowiązane pliki *„dla porządku”*, niszcząc historię gita i powodując merge conflicts. Egzekwowane przez twardą regułę: **agent modyfikuje wyłącznie linie kodu, o które został bezpośrednio poproszony** [2]. Nieproszone refaktoryzacje są blokowane jako wektory awarii.

---

## 3. Mapowanie na SDLC: komendy slash jako bramki faz

Skille mapują się 1:1 na fazy cyklu życia oprogramowania. Komendy slash naturalnie integrują się w Claude Code [2].

| Faza SDLC | Komenda | Skill | Wymuszony reżim |
|---|---|---|---|
| **Define** | `/spec` | `spec-driven-development` | Pełna specyfikacja biznesowa + architektoniczna **przed** logiką produkcyjną |
| **Plan** | `/plan` | `planning-and-task-breakdown` | Rozbicie monolitu na mikro-zadania niezależnie weryfikowalne |
| **Build** | `/build` | `incremental-implementation` | Pionowe wycinki (vertical slices), ciągła kompilowalność |
| **Verify** | `/test` | `test-driven-development` | Pętla RED-GREEN-REFACTOR, zakaz kodu produkcyjnego bez failing testu |
| **Review** | `/review` | `code-review-and-quality` | Pięcioosiowy audyt architektoniczny |
| **Ship** | `/ship` | — | Analizy przedwdrożeniowe, performance regression |
| **Optimize** | `/code-simplify` | — | Redukcja złożoności cyklomatycznej **bez zmiany kontraktów API** |

Komendy zastępują chaotyczny czat spójnym potokiem narzędzi inżynieryjnych [5].

---

## 4. Code Review & Quality: pięcioosiowy audyt

Najmocniejszy moduł frameworku — **Five-Axis Code Review** [22].

### Pięć osi audytu

1. **Correctness** — skrajne przypadki (off-by-one, null safety, race conditions), zgodność ze specyfikacją.
2. **Readability & Simplicity** — kod czytany 10× częściej niż modyfikowany. Walka z przedwczesnymi abstrakcjami i „sprytnymi” optymalizacjami. *Jeśli 1000 linii daje ten sam efekt co 100 — praca jest odrzucana* [23].
3. **Architecture** — tropienie duplikacji, zależności cyklicznych, naruszeń granic modułów.
4. **Security** — dane z zewnątrz domyślnie zainfekowane; ochrona przed SQL injection, skanowanie kluczy/secrets, zgodność z **OWASP Top 10** (Tier D skills) [6].
5. **Performance** — N+1 queries, niekontrolowane pętle, brakujący async I/O na operacjach sieciowych [23].

### Change Sizing: progi tolerancji

> [!warning] Twarde kryteria PR Sizing [23]
> - **~100 linii** → optymalne, zalecane
> - **~300 linii** → tolerowane, wymaga uzasadnienia
> - **>1000 linii** → **rażący defekt metodologiczny** — agent musi przerwać i zastosować Stacking lub vertical slicing

### Hyrum's Law + Chesterton's Fence

Dwa kanoniczne zabezpieczenia przed samowolnym „porządkowaniem” kodu [2]:

- **Prawo Hyruma** — przy dostatecznie dużej bazie użytkowników **każde** obserwowalne zachowanie API (nawet nieudokumentowane) staje się zależnością. Agent nie może modyfikować zachowań bez analizy wpływu.
- **Ogrodzenie Chestertona** — zanim agent usunie pozornie martwy kod, musi udowodnić zrozumienie **dlaczego** ten kod tam jest. Brak wyjaśnienia = obowiązek pozostawienia.

### Multi-Model Review Pattern

Zaawansowany schemat oceny koleżeńskiej [23]:

- **Model A** (zoptymalizowany pod budowę) tworzy rozwiązanie.
- **Model B** (odizolowany instruktażowo) dokonuje review na osiach ryzyka.
- Uwagi klasyfikowane przez severity: **Critical / Optional / Nit / FYI**.
- Wynik trafia do człowieka jako finalna bramka decyzyjna.

---

## 5. Incremental Implementation + TDD

### Pionowe wycinki (Thin Vertical Slices)

LLM-y domyślnie chcą generować masywne rozwiązania end-to-end. Metodologia wymusza przeciwne podejście [14]:

- **Nie buduj warstwa po warstwie** (frontend → API → DB).
- **Buduj wąską odnogę przechodzącą przez cały stos** — od DB przez API do UI.
- Każdy wycinek ma działać end-to-end zanim zaczniesz następny.

Pięciostopniowy wymóg deterministyczny:

1. Najprostsza logika bazowa.
2. Natychmiastowy test.
3. Walidacja procesu budującego.
4. Commit (zatwierdzenie dyskowe).
5. Dopiero teraz przejście do kolejnej jednostki funkcjonalnej.

> [!note] Safe Defaults
> Niedokończone interfejsy są zabezpieczane **feature flagami** — gaszą funkcjonalność w produkcji do czasu pełnej implementacji.

### TDD jako „supermoc” [21]

Cykl **RED → GREEN → REFACTOR** [26]:

1. **RED** — napisz scenariusz, który zawodzi z widoczną na konsoli porażką.
2. **GREEN** — minimalny kod aktywujący funkcjonalność.
3. **REFACTOR** — czystka na uodpornionym szkielecie, pod ochroną zielonych testów.

**Piramida testów 80/15/5** [11]:

- 80% unit (szybkie, izolowane)
- 15% integration
- 5% E2E / UI

**Beyoncé Rule** [2]: *„If you liked it, you should have put a test on it”* — krytyczna logika biznesowa musi mieć ramy zapobiegające awariom.

### Wzorzec „Prove-It” dla bugów [26]

Procedura blokująca natychmiastowe przepisywanie kodu po zobaczeniu loga błędu:

1. **Stop** — nie dotykaj kodu produkcyjnego.
2. Napisz test, który **odtwarza buga** i zawodzi w sposób kontrolowany.
3. Dowód RED → dopiero teraz pisz fix.
4. Test wraca do GREEN → fix zatwierdzony.

**DAMP over DRY w testach** [2] — *Descriptive And Meaningful Phrases* > *Don't Repeat Yourself*. Czytelność diagnostyki ważniejsza niż unikanie powtórzeń.

Dodatkowo: integracja z **Chrome DevTools przez MCP** (Model Context Protocol) — agent może weryfikować DOM, wydajność i wizualne ograniczenia [26].

---

## 6. Best practices dla twórców własnych skilli

Firmy budują własne skille kodujące wewnętrzne konwencje (np. compliance w fintech). Kilka kluczowych pryncypiów wytwórczych [15, 16]:

### Grounding in Real Expertise

Skill zbudowany z czystej narracji LLM produkuje halucynacje. Bazą muszą być:

- **Runbooki** od ludzkich inżynierów.
- **Historyczne PR-y** z krytycznymi poprawkami.
- **Execution traces** z incydentów produkcyjnych.

Skill ma uzupełniać luki, **nie powtarzać generalnej wiedzy** modelu. Sekcja `Gotchas` opisuje firmowe anomalie (np. soft-delete, niestandardowe konwencje nazewnictwa).

### Token budget [15]

- **SKILL.md ≤ 500 linii / ~5000 znaków.**
- Rozbudowane referencje → podkatalog `references/`.
- Ładowanie dynamiczne tylko gdy wykryty trigger (np. HTTP 5xx → załaduj `references/api-errors.md`).

### Styl instrukcji [15, 16]

| ❌ Unikaj | ✅ Stosuj |
|---|---|
| „Powinieneś sprawdzić autoryzację” | „Weryfikuj checki autoryzacji” (tryb rozkazujący) |
| Ścieżki absolutne | Zmienna `{baseDir}` + forward slashes |
| `MyFolder_2`, `my folder` | `kebab-case`, bez spacji, bez wielkich liter |
| Drugoosobowa proza | Imperatyw + listy + tabele |

### Calibration: kalibracja swobody

Stopień rygoru zależy od wrażliwości operacji [15]:

- **Strefa wolna** (CRUD biznesowy, frontend) — szerokie spektrum wzorców, agent uzasadnia wybory.
- **Fragile Operations** (migracje DB, zmiany infrastruktury) — agent traci kreatywność, **powtarza komendy krok-po-kroku** z runbooka.
- **Plan-Validate-Execute** dla operacji destruktywnych — agent generuje plan, waliduje go z bazą prawdy, **dopiero potem** wykonuje.

### Deterministyczne skrypty zamiast re-implementacji

LLM-y są słabe w rutynowych, deterministycznych obliczeniach (np. obliczenia raportowe). Rozwiązanie: katalog `scripts/` z gotowymi narzędziami, wywoływanymi przez agenta [15].

### Negative Triggers — blokada przesadnej wrażliwości

Agent ma tendencję do ładowania ciężkich proceduralnych skilli przy banalnych zadaniach (`przeczytaj ten plik`). Każdy skill powinien mieć **explicite zdefiniowane warunki wykluczenia** [16].

### Walka z Agent Laziness [16]

Anthropic zaleca twardą deklarację w systemowych wytycznych:
> *„Najwyższa waga jakości. Nie optymalizuj pod szybkość implementacji.”*

Mierzalne efekty: powrót modelu z marginalnej skuteczności do pełnej operatywności na rygorach senioralnych.

---

## 7. Konsekwencje dla rynku pracy

Wdrożenie Agent Skills przekształca strukturę zespołów inżynieryjnych [31, 32].

### Erozja roli „kodera-wklepywacza”

Rutynowe kodowanie, formatowanie struktur i powtarzalna ewaluacja PR-ów przesuwają się na agentów. Człowiek przejmuje **role koordynacyjne wyższego rzędu** — *Judgment and Execution*.

### Cztery archetypy zespołów nadrzędnych (Staff Archetypes) [32]

1. **Tech Lead** — koordynacja potoków wielu agentów AI.
2. **Architekt** — modelowanie mostów międzysystemowych, warstwy izolacyjne platform.
3. **Problem Solver** — ratowanie produkcji w niezmapowanych incydentach, chirurgiczne fixy.
4. **Execution Right Hand** — operacyjny zastępca w strefach biznesowych.

### Rekrutacja: AI Hackathons [33]

Tradycyjne CV i analizy papierowe nie nadążają. Hackatony pokazują **realne kompetencje pod presją** — adaptacja, komunikacja, użycie AI jako narzędzia deterministycznego pod ludzką architekturą decyzyjną.

Konferencja **Economic Times Future of Knowledge Work Summit** (Bengaluru, czerwiec 2026) wprost pozycjonuje ten cykl transformacyjny [31].

---

## 8. Wnioski strategiczne

> [!success] Co daje Agent Skills
> - Obala mit „magicznego promptu” — rygor zamiast magii.
> - Pięć filarów wymusza dyscyplinę, której LLM domyślnie nie posiada.
> - PR Sizing ~100 linii + OWASP scanning + Hyrum/Chesterton = **bezpieczna delegacja zadań inżynierskich na AI**.
> - Open source na licencji MIT — adaptowalne do wewnętrznych konwencji firmy.

> [!danger] Czego Agent Skills NIE robi
> - Nie zastępuje ludzkiego osądu architektonicznego.
> - Nie eliminuje halucynacji bez ugruntowania w runbookach.
> - Nie chroni przed źle skalibrowaną swobodą agenta w Fragile Operations.

**Finalna teza:** rola programisty przesuwa się z *implementatora* na *architekta procesu*. Skuteczne wdrożenie AI to inżynieria procesowa — narzucanie agentowi dyscypliny, której on sam nie posiada. Kod jest produktem ubocznym; głównym produktem inżyniera staje się **proces gwarantujący, że ten kod jest bezpieczny**.

---

## Cytowane prace

1. [Google's Addy Osmani Shows How to Turn AI into a Senior Developer](https://www.youtube.com/watch?v=ZwYImI2ykRQ)
2. [Agent Skills — AddyOsmani.com](https://addyosmani.com/blog/agent-skills/)
3. [Agentic Dev — Daily AI Dev Tools News](https://agenticdev.blog/)
4. [How I use Claude Code: Separation of planning and execution (HN)](https://news.ycombinator.com/item?id=47106686)
5. [ZeroLatencyAI — Reddit](https://www.reddit.com/user/TroyNoah6677/)
6. [addyosmani/agent-skills — GitHub](https://github.com/addyosmani/agent-skills)
7. [Google Open-Sources „Agent Skills” Framework](https://www.houdao.com/d/7494-Google-OpenSources-Agent-Skills-Framework-A-Set-of-ProductionGrade-Engineering-Skills-for-AI-Coding-Agents-Covering-the-Entire-Software-Development-Lifecycle)
8. [agent-skills/AGENTS.md](https://github.com/addyosmani/agent-skills/blob/main/AGENTS.md)
9. [agent-skills/docs/skill-anatomy.md](https://github.com/addyosmani/agent-skills/blob/main/docs/skill-anatomy.md)
10. [Issue #17: anti-rationalization and verification sections](https://github.com/addyosmani/agent-skills/issues/17)
11. [Agent Skills: How to Extend AI Coding Agents (2026 Guide) — byteiota](https://byteiota.com/agent-skills-how-to-extend-ai-coding-agents-2026-guide/)
12. [artemiimillier/bulletproof — GitHub](https://github.com/artemiimillier/bulletproof)
13. [Agent Skills: Teaching AI agents to code like senior engineers — rushis.com](https://www.rushis.com/agent-skills-teaching-ai-agents-to-code-like-senior-engineers/)
14. [agent-skills/skills/incremental-implementation/SKILL.md](https://github.com/addyosmani/agent-skills/blob/main/skills/incremental-implementation/SKILL.md)
15. [Best practices for skill creators — agentskills.io](https://agentskills.io/skill-creation/best-practices)
16. [The Complete Guide to Building Skills for Claude — Anthropic](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf)
17. [Getting Started with Agent Skills — CodeWiz](https://codewiz.info/blog/ai-agent-skills-guide/)
18. [What Are Agent Skills and How To Use Them — Strapi](https://strapi.io/blog/what-are-agent-skills-and-how-to-use-them)
19. [Agent Skills: Production-Grade Engineering Skills for AI Coding — Jimmy Song](https://jimmysong.io/ai/addyosmani-agent-skills/)
20. [Karpathy's AI Coding Agent Rant in a Claude.md File — unwind ai](https://www.theunwindai.com/p/karpathy-s-ai-coding-agent-rant-in-a-claude-md-file)
21. [agent-skills/docs/gemini-cli-setup.md — GitCode](https://gitcode.com/listenwetness/agent-skills/blob/main/docs/gemini-cli-setup.md)
22. [agent-skills — Claude Code Plugin — ClaudePluginHub](https://www.claudepluginhub.com/plugins/wlshlad85-agent-skills)
23. [agent-skills/skills/code-review-and-quality/SKILL.md](https://github.com/addyosmani/agent-skills/blob/main/skills/code-review-and-quality/SKILL.md)
24. [agent-skills/skills/security-and-hardening/SKILL.md](https://github.com/addyosmani/agent-skills/blob/main/skills/security-and-hardening/SKILL.md)
25. [Epic: adopt addyosmani/agent-skills patterns — nexus-agents #2385](https://github.com/williamzujkowski/nexus-agents/issues/2385)
26. [agent-skills/skills/test-driven-development/SKILL.md](https://github.com/addyosmani/agent-skills/blob/main/skills/test-driven-development/SKILL.md)
27. [class-ai-agent 1.2.3 — Libraries.io](https://libraries.io/npm/class-ai-agent)
28. [Claude Agent Skills Explained — YouTube](https://www.youtube.com/watch?v=fOxC44g8vig)
29. [mgechev/skills-best-practices — GitHub](https://github.com/mgechev/skills-best-practices)
30. [Claude Agent Skills: A First Principles Deep Dive — Lee Hanchung](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/)
31. [Redefining knowledge work in the age of AI — ET Summit Bengaluru 2026](https://m.economictimes.com/ai/ai-insights/redefining-knowledge-work-in-the-age-of-ai-et-summit-bengaluru-2026/articleshow/130853316.cms)
32. [bookmark-summary/all_summary.md — GitHub](https://github.com/jerrylususu/bookmark-summary/blob/main/all_summary.md)
33. [Why AI hackathons are becoming the new talent discovery platforms — Economic Times](https://m.economictimes.com/ai/ai-insights/why-ai-hackathons-are-becoming-the-new-talent-discovery-platforms/articleshow/130887191.cms)
