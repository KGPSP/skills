---
title: "Healthcheck endpoint"
slug: healthcheck
sprint-count: 1
paths-in-scope:
  - src/api/health.js
  - tests/api/health.spec.js
out-of-scope:
  - "Monitoring integration"
fragile-paths-detected: false
---

# Co i dlaczego

Brakuje endpointu `/api/health` do monitoringu uptime. Powinien zwracać 200 + JSON `{status: "ok", ts: <iso>}`.

# Acceptance Criteria

| AC-ID | Typ | Opis | Test ID | Plik testu | Komenda |
|---|---|---|---|---|---|
| AC-1 | F | Endpoint /api/health zwraca 200 + JSON {status:"ok"} | T-1 | tests/api/health.spec.js | npm test -- tests/api/health.spec.js |

# Definition of Done

- AC-1 → exit 0
- Build clean (npm run build → 0 warnings)

# Out of scope

- Integracja z Prometheus / Grafana

# Sprints

## Sprint 1
AC-1 — minimalny endpoint + test
