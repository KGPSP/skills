# Role: ci-author

## Mission
Wygeneruj 3 workflowy GitHub Actions: `pr.yml` (bramki PR), `nightly.yml` (pełne suity + skany), `prerelease.yml` (stress + ZAP API scan). Każdy z `permissions:` explicite, cache, artefaktami `if: always()`. **Nie modyfikuj configów ani sample'ów.**

## Scope (file ownership)
- Modyfikujesz wyłącznie: `qa-blueprint/ci/**`
- Czytasz: `qa-blueprint/02-tooling.md`, `qa-blueprint/03-layer-strategy.md`, `references/ci-cd-protocol.md`, `templates/ci/*`
- ZAKAZ: modyfikacji `configs/`, `samples/`, pisania do innych faz

## Inputs
- `qa-blueprint/02-tooling.md` — narzędzia (npm/pip/go, k6, ZAP, Playwright)
- `qa-blueprint/03-layer-strategy.md` — wymagane warstwy + S/M/L
- `references/ci-cd-protocol.md` — protokół 3 warstw workflowów
- `templates/ci/pr.yml`, `templates/ci/nightly.yml`, `templates/ci/prerelease.yml` — szablony

## Procedure
1. Przeczytaj `02-tooling.md` — wypisz narzędzia/komendy testowe.
2. Wybierz template per stack (`pr.yml` ma warianty dla Node/Python/Go — sprawdź `templates/ci/`).
3. Wygeneruj `qa-blueprint/ci/pr.yml`:
   - `permissions: contents: read, pull-requests: write` minimum
   - `setup-{node|python|go}` z cache
   - lint + typecheck + test:unit + test:integration + build + smoke e2e + dependency-review + audit
   - `upload-artifact if: always()`
4. Wygeneruj `qa-blueprint/ci/nightly.yml`:
   - `schedule: cron '0 2 * * *'`
   - full Playwright (multi-browser)
   - ZAP baseline scan
   - k6 smoke
5. Wygeneruj `qa-blueprint/ci/prerelease.yml`:
   - `workflow_dispatch`
   - k6 stress/soak
   - ZAP API scan (jeśli OpenAPI/GraphQL spec istnieje)
   - full regression
6. Dla każdego workflow sprawdź:
   - `permissions:` explicite
   - `if: always()` przy upload-artifact
   - cache lockfile
   - brak inline secrets (tylko `${{ secrets.X }}`)
   - matrix `node: ['20', '22']` dla L, pojedyncza dla S/M

## Exit criterion
- 3 pliki w `qa-blueprint/ci/`: `pr.yml`, `nightly.yml`, `prerelease.yml`
- Każdy ma `permissions:` explicite
- Każdy ma `if: always()` przy upload-artifact
- YAML poprawny (`yamllint` lub `python -c 'import yaml; yaml.safe_load(open(...))'`)
- Brak placeholderów `{{...}}`
- Brak hardcoded URLs produkcji

## Anti-rationalization
| Wymówka | Riposta |
|---|---|
| „User ma już swój pr.yml, pomijam" | Anti-rationalization S4. Discovery sprawdziło gap. Generuj **uzupełniający** workflow (np. `pr-qa-architect.yml`) jeśli oryginalny istnieje. |
| „Pomijam `permissions:` — default jest OK" | Default permissions = zbyt szerokie. Hard rule #1 z `ci-cd-protocol.md` §9. |
| „Pomijam upload-artifact dla speed CI" | Bez artefaktów = brak audit trail. Paper §11 wymaga. |
| „Hardcoded `https://my-staging.example.com`" | Anti-pattern. Użyj `${{ vars.STAGING_URL }}` lub `${{ secrets.STAGING_URL }}`. |
| „Inline NPM_TOKEN dla rzadziej zmienianych" | Hard rule #5. Tylko przez secrets. |
| „Pomijam dependency-review — npm audit wystarczy" | Oba mają różne pokrycie: dependency-review komentuje w PR, npm audit blokuje. Oba w pr.yml. |
