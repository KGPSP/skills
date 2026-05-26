---
name: ci-cd-protocol
type: reference
parent: qa-architect
sources:
  - DOC/QA-swarm.md §11 (Integracja CI/CD), §11.1 (PR/nightly/release), §11.2 (Headless mode), §11.3 (Claude Code w CI)
  - DOC/since_skill.md §5 (Prove-It w pipeline)
description: Protokół generowania GitHub Actions workflowów dla qa-architect Phase 5 (ci-author). Trzy warstwy: PR (szybkie bramki blokujące merge), nightly (pełne suity + skany), pre-release (k6 stress, ZAP API scan). Każdy job ma artefakty + matrix node version + cache.
---

# CI/CD protocol — GitHub Actions

> [!quote] QA-swarm.md §11.1
> Łańcuch CI powinien być **krótki na PR, pełniejszy na nightly i na release candidate**. GitHub oficjalnie rekomenduje `setup-node`, macierze wersji Node, artefakty i workflowy Node.js; `npm ci` jest przeznaczone do środowisk zautomatyzowanych.

## 1. Trzy warstwy workflowów

| Workflow | Trigger | Cel | Czas budżetu |
|---|---|---|---|
| **pr.yml** | `pull_request` | Bramki blokujące merge | < 10 min |
| **nightly.yml** | `schedule: cron '0 2 * * *'` | Pełne suity + skany pasywne | < 60 min |
| **prerelease.yml** | `workflow_dispatch` lub tag `v*-rc*` | Stress/soak + ZAP full scan | < 4h |

## 2. Zawartość per workflow

### pr.yml (obowiązkowy minimum)

```yaml
jobs:
  test:
    steps:
      - checkout (fetch-depth: 0 — dla dependency review)
      - setup-{node|python|go} z cache lockfile
      - install (npm ci / pip install / go mod download)
      - lint
      - typecheck (jeśli stack typed)
      - test:unit (z coverage)
      - test:integration (HTTP + DB jeśli stack ma SQL)
      - build
      - playwright install --with-deps (jeśli e2e)
      - test:e2e:smoke (1 golden ścieżka, nie pełna suite)
      - dependency-review (Github Action)
      - npm audit --audit-level=high (lub equiv)
      - upload-artifact (coverage, playwright-report, junit)
```

### nightly.yml

```yaml
jobs:
  full-e2e:
    steps:
      - checkout
      - setup-{...}
      - install
      - build
      - playwright test (pełna suite, multi-browser)
      - upload trace + screenshots + video

  zap-baseline:
    steps:
      - checkout
      - deploy staging (lub użyj preview URL)
      - zaproxy/action-baseline (pasywny skan)

  k6-smoke:
    steps:
      - grafana/setup-k6-action
      - k6 run scripts/smoke.js
      - upload k6 results

  trend-metrics:
    steps:
      - upload metryki coverage/flaky-ratio/time do storage (S3 lub artefakty)
```

### prerelease.yml

```yaml
jobs:
  k6-stress:
    steps:
      - k6 run scripts/stress.js (stress + soak)

  zap-api-scan:
    steps:
      - zaproxy/action-api-scan (jeśli jest OpenAPI/GraphQL spec)

  full-regression:
    steps:
      - pełna playwright suite + integration suite + DB suite
```

## 3. Stack-specific bits

### Node (Next.js / generic)

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'  # paper §10.3 — LTS
    cache: ${{ env.PM }}  # npm/yarn/pnpm
- run: ${{ env.PM_INSTALL }}  # npm ci / pnpm install --frozen-lockfile / yarn install --immutable
```

`matrix.node: ['20', '22']` dla L (multi-version compat), pojedyncza dla S/M.

### Python

```yaml
- uses: actions/setup-python@v5
  with:
    python-version: '3.12'
    cache: 'pip'
- run: pip install -r requirements-dev.txt  # lub uv sync, poetry install
```

### Go

```yaml
- uses: actions/setup-go@v5
  with:
    go-version: '1.22'
    cache: true
- run: go mod download
```

## 4. Postgres w CI (paper §10.3)

**Dwa warianty, wybór per stack:**

### Wariant A — services container (preferowany dla CI)

```yaml
services:
  postgres:
    image: postgres:16-alpine
    env:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: app
      POSTGRES_DB: app_test
    ports:
      - 5432:5432
    options: >-
      --health-cmd "pg_isready -U app -d app_test"
      --health-interval 5s
      --health-timeout 5s
      --health-retries 20
```

### Wariant B — Testcontainers w job

Bez `services:` w workflow — Testcontainers spinują container per suite. Wymagane: docker dostępny w runner (default `ubuntu-latest`).

**Decyzja:**
- Jeśli aplikacja ma jedną testową bazę → wariant A (szybszy startup).
- Jeśli per-suite isolation → wariant B (gwarancja czystego state).
- Mieszanka OK (services do integration HTTP, Testcontainers do DB).

## 5. Artefakty (paper §11)

Każdy workflow MUSI uploadować:

```yaml
- name: Upload reports
  if: always()  # WAŻNE — upload też przy failure
  uses: actions/upload-artifact@v4
  with:
    name: reports-${{ matrix.node || 'default' }}
    path: |
      coverage/**
      reports/**
      playwright-report/**
      test-results/**
      junit*.xml
```

`if: always()` — bez tego artefakty z failed runs ginęą, a paper §12.5 wymaga audit trail.

## 6. Permissions (least privilege)

Każdy workflow ma explicite `permissions`:

```yaml
permissions:
  contents: read
  pull-requests: write  # dla dependency-review komentarzy
  checks: write  # dla test reporters
  security-events: write  # dla ZAP/code scanning upload
```

Bez `actions: write` chyba że jest specific use case (re-run, etc.).

## 7. Headless Claude Code w CI (paper §11.3) — OPCJONALNE

Skill **nie generuje** workflowów wywołujących Claude Code automatycznie (out of scope). Ale `CLAUDE.md.patch` zawiera link do dokumentacji „jak włączyć headless mode" — handoff do `audited-feature-workflow` lub manualnej konfiguracji.

## 8. Konfiguracja per stack — szablony

Pliki templates w `templates/ci/`:

- `pr.yml` — **stack-agnostic** (działa dla Node, Python, Go via `{{PACKAGE_MANAGER}}` placeholder i conditional steps `setup-{node|python|go}`)
- `nightly.yml` — stack-agnostic (j.w.)
- `prerelease.yml` — stack-agnostic (j.w.)

ci-author instancjonuje placeholdery na podstawie `stack` + `package_manager` z Phase 0:
- `{{NODE_VERSION}}` (np. `"20"`)
- `{{PACKAGE_MANAGER}}` (npm | yarn | pnpm | bun | pip | poetry | uv | go)
- `{{PM_INSTALL}}` (np. `npm ci` | `pnpm install --frozen-lockfile` | `pip install -e .[test]` | `go mod download`)

Dla stacku Python: zamień `actions/setup-node` → `actions/setup-python`, `npm run lint` → `ruff check`/`pytest`. Dla Go: `actions/setup-go` + `go test -tags=integration ./...`.

> **Note:** brak osobnych `pr-python.yml`/`pr-go.yml` jest celowy — jeden template z placeholderami trzyma stack-detection w jednym miejscu (Phase 0) i unika duplikacji 80% wspólnej struktury workflow.

## 9. Hard rules

1. **Każdy workflow ma `permissions:` explicite** — żaden bez (default permissions = zbyt szerokie).
2. **`if: always()` przy upload artefaktów** — bez tego brak debugowania failed runs.
3. **`fetch-depth: 0`** dla jobs używających `dependency-review-action` (wymaga historii commitów).
4. **Cache lockfile** — bez tego CI wolne.
5. **Brak inline secrets** — wyłącznie przez `${{ secrets.X }}`.
6. **Brak hard-coded URL produkcji** — staging URL przez `vars` lub `secrets`.

## 10. Output sub-agenta `ci-author`

`qa-blueprint/ci/`:
- `pr.yml` — bramki PR
- `nightly.yml` — nightly suites
- `prerelease.yml` — pre-release gates

Każdy z `permissions:`, cache, artifacts, `if: always()`. Walidacja w Phase 7: `yamllint` lub `actionlint` (jeśli dostępny w runner).
