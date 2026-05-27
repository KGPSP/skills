---
title: "Tryb /goal: wzorzec stan-końcowy + weryfikacja + ograniczenia"
type: reference
status: kanoniczny
version: v1
audience: autorzy i użytkownicy skilli z trybem /goal (autonomiczna pętla AC)
tags: [goal-mode, acceptance-criteria, autonomous-loop, claude-code]
updated: 2026-05-22
---

# Tryb `/goal` — wzorzec: stan końcowy + weryfikacja + ograniczenia

> **Typ:** reference (katalog wzorcowych poleceń) · **Status:** kanoniczny · **Aktualizacja:** 2026-05-22
> **Rola w korpusie `DOC/`:** kanoniczne przykłady formułowania celu dla trybu `/goal` — cytowane jako `source:` przez skille z autonomiczną pętlą AC.

## Streszczenie

Zbiór wzorcowych i antywzorcowych sformułowań polecenia `/goal`. Dobry cel ma trzy elementy: **mierzalny stan końcowy**, **deterministyczny sposób weryfikacji** (komenda + oczekiwany wynik/exit code) oraz **jawne ograniczenia** zakresu. Cele niemierzalne („popraw kod") są odrzucane, bo ewaluator nigdy nie orzeknie „done". Pełna integracja: [`dev/audited-feature-workflow/references/goal-mode-protocol.md`](../dev/audited-feature-workflow/references/goal-mode-protocol.md).

**Słowa kluczowe:** /goal · stan końcowy · kryteria akceptacji · weryfikacja deterministyczna · ograniczenia zakresu · autonomiczna pętla · worktree.

---

Oto kilka konkretnych przykładów pokazujących wzorzec **stan końcowy + sposób weryfikacji + ograniczenia**:

**1. Naprawa testów (klasyk):**
```
/goal Wszystkie testy w katalogu tests/auth/ przechodzą. 
Weryfikacja: `npm test -- tests/auth` kończy się exit code 0. 
Ograniczenia: nie modyfikuj plików testowych, nie commituj, 
nie dotykaj plików poza src/auth/.
```

**2. Migracja API (realistyczne dla Waszego stacku):**
```
/goal Wszystkie wywołania starego endpointu /api/v1/shelters 
w kodzie frontendu są zastąpione wywołaniami /api/v2/shelters 
z nowym schematem odpowiedzi (pole `capacity` zamiast `pojemnosc`). 
Weryfikacja: `grep -r "api/v1/shelters" src/` zwraca pustą listę, 
`npm run build` przechodzi, `npm test` exit code 0. 
Ograniczenia: nie zmieniaj logiki UI, tylko warstwę API, 
nie ruszaj plików backendowych.
```

**3. Rozbicie monolitycznego pliku:**
```
/goal Plik src/services/CezolService.ts jest rozbity na moduły, 
każdy poniżej 300 linii. 
Weryfikacja: `wc -l src/services/cezol/*.ts` pokazuje wszystkie 
pliki <300, `npm run typecheck` exit 0, `npm test` exit 0. 
Ograniczenia: zachowaj publiczne API klasy CezolService 
(eksporty z index.ts bez zmian), nie zmieniaj zachowania.
```

**4. Backlog issues z labelką (długi przebieg na noc):**
```
/goal Wszystkie otwarte issues z labelką `bug:gdziesieukryc` 
i priorytetem P1 są zamknięte lub mają PR. 
Weryfikacja: `gh issue list --label "bug:gdziesieukryc" --label P1 
--state open` zwraca pustą listę, każdy zamknięty issue ma 
podlinkowany merged PR. 
Ograniczenia: nie tykaj issues bez labelki P1, każdy PR ma testy, 
nie deployuj na produkcję.
```

**Antywzorce, których unikać:**
- ❌ `/goal popraw kod` — niemierzalne, ewaluator nigdy nie powie „done"
- ❌ `/goal kod jest ładniejszy` — subiektywne, brak weryfikacji
- ❌ `/goal działa szybciej` — bez progu (ile szybciej? mierzonego jak?)

**Wskazówka praktyczna:** zanim odpalisz `/goal`, włącz auto mode (zaakceptuj narzędzia automatycznie) i odpal w osobnym worktree — wtedy Claude może spokojnie iterować całą noc bez Twojej obecności, a Ty masz czysty branch do code review rano.

> Pełna integracja z audited-feature-workflow: [dev/audited-feature-workflow/references/goal-mode-protocol.md](../dev/audited-feature-workflow/references/goal-mode-protocol.md).