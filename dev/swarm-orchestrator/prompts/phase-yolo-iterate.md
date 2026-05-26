# YOLO iter {{ITER}} — focus na pierwszej nieprzechodzącej AC

**Workspace:** {{WORKSPACE}}
**Run:** {{RUN_ID}}
**Sprint:** {{SPRINT}}
**Iteracja:** {{ITER}}

## Pierwsza nieprzechodząca AC

**{{FOCUS_AC}}**

- Komenda weryfikacyjna: `{{FAIL_CMD}}`
- Pełny raw log: `{{FAIL_LOG}}`

## Co masz zrobić

1. Przeczytaj `{{FAIL_LOG}}` — zrozum konkretny błąd (nie zgaduj).
2. Zlokalizuj plik źródłowy odpowiedzialny za błąd (`paths_in_scope` w `{{STATE_DIR}}/contracts/sprint-{{SPRINT}}.json`).
3. Wprowadź **minimalną zmianę** rozwiązującą TĘ jedną AC. Bez scope creep — nie refactoruj sąsiednich modułów.
4. Sprawdź zanim commitujesz:
   - `verify-plan-rigor.sh` (jeśli zmieniałeś plan) → exit 0
   - `check-scope-discipline.sh` → exit 0 (każdy zmieniony plik ⊂ `paths_in_scope`)
   - `check-pr-size.sh` → exit 0 (≤300 linii lub `--justified`)
   - Brak edycji plików w Fragile zones: `migrations/`, `terraform/`, `k8s/`, `auth/`, `.github/workflows/`, `Dockerfile`, `prod*`
5. **Atomic commit** z konkretną nazwą AC w treści:
   ```
   fix({{SPRINT}}): {{FOCUS_AC}}
   
   Single-AC fix, sprint {{SPRINT}}, iter {{ITER}}.
   ```
6. **NIE** wykonuj: `git push`, `npm publish`, `gh pr create`, `gh release`, `DROP`, `rm` poza `paths_in_scope`. To **twarde zakazy** także w YOLO — driver odrzuci.

## Anti-Rationalization (quick-check przed commitem)

- „Wystarczy że poprawię też sąsiedni plik" → **NIE.** Scope creep blokuje atomic commit. Stwórz osobne zadanie w `state/blockers.md`.
- „Już 2× nie działało, ale teraz dla pewności zmienię jeszcze inne miejsce" → **NIE.** Driver liczy `error_hash`. 3× ten sam hash = auto-pivot. Skup się na pierwotnej przyczynie, nie na obejściu.
- „Pomijam test bo lokalnie działa" → **NIE.** Komenda weryfikacyjna `{{FAIL_CMD}}` jest jedynym oracle'em. Jeśli ona zwraca exit ≠ 0, AC nie zaliczona.

## Po commicie

Driver (`swarm-yolo.sh`) zostanie re-invokowany przez operatora / wrapper. Twoja iteracja kończy się w momencie atomic commitu. **Nie kontynuuj** w tym samym oknie — czekaj na kolejny prompt.

---

Skupiona praca, jeden AC, atomic commit. Powodzenia.
