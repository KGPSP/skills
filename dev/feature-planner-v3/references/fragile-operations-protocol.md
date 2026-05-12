---
name: fragile-operations-protocol
description: Reżim Plan-Validate-Execute dla operacji destruktywnych (DB, infra, auth, prod data, crypto). Eliminuje kreatywność agenta w strefach wysokiego ryzyka.
type: reference
parent: feature-planner-v3
source: 'since_skill.md §6 (Calibration: kalibracja swobody)'
---

# Fragile Operations Protocol

> [!important] Cel pliku
> Niektóre operacje są nieodwracalne lub mają wysoki koszt naprawy. W tych strefach **agent traci kreatywność** — wykonuje dosłownie zatwierdzoną procedurę krok-po-kroku z runbooka.

---

## 1. Co jest Fragile Operation

Operacja należy do strefy fragile, jeśli spełnia ≥1 warunek:

- **Nieodwracalność** — naprawa wymaga restore z backupu, nie zwykłego `git revert`.
- **Wpływ na produkcję** — błąd skutkuje incydentem lub utratą danych.
- **Wpływ na strukturę** — zmienia schema, RBAC, kontrakty sieciowe.

### Lista zamknięta stref

| Strefa | Sygnały (pliki / komendy / słowa) |
|---|---|
| **DB migrations** | `prisma migrate`, `alembic`, `flyway`, `knex migrate`, `sequelize-cli`, `migrations/`, `ALTER TABLE`, `DROP COLUMN` |
| **Infrastructure** | `Dockerfile`, `docker-compose.yml`, `k8s/`, `*.tf`, `terraform`, `.github/workflows/`, `.gitlab-ci.yml`, `helm/` |
| **Authentication / authorization core** | `auth/`, `passport`, `jwt`, `session`, `RBAC`, `casbin`, `middleware/auth*` |
| **Production data manipulation** | `UPDATE` / `DELETE` na żywych tabelach, `psql -h prod-*`, `mongo prod-*`, `redis-cli FLUSH*` |
| **Cryptography / secrets** | rotacja kluczy, `KMS`, `vault`, `.env.production`, `*.pem`, `*.key`, `openssl genrsa` |

---

## 2. Detekcja w Phase 0

Heurystyki klasyfikujące zadanie jako fragile:

1. **Ścieżki plików** — match przeciw tabeli powyżej (`{baseDir}/prisma/migrations/`, `{baseDir}/terraform/`, `{baseDir}/.github/workflows/`).
2. **Słowa kluczowe w prompcie** — `migracja`, `migration`, `alembic`, `terraform`, `rotate secret`, `drop`, `truncate`, `prod`.
3. **Obecność katalogów** — `ls -d {baseDir}/migrations {baseDir}/terraform {baseDir}/auth 2>/dev/null` zwraca ≥1 hit.
4. **Eksplicytny flag** — user pisze `[fragile]`, `--fragile`, `produkcja`.

Wynik detekcji → flag `IS_FRAGILE=true` przekazywany do kolejnych faz.

---

## 3. Reżim Plan-Validate-Execute

> [!warning] Tryb obowiązkowy dla `IS_FRAGILE=true`
> Trzy kroki sekwencyjne. Brak skrótów. Brak modyfikacji „w locie".

### Krok 1: Plan

Agent generuje **dosłowny plan komend** w formacie blokowym:

```text
## Plan: <opis operacji>

### Komendy
1. `psql -h {host} -U {user} -d {db} -c "BEGIN;"`
2. `psql -h {host} -U {user} -d {db} -c "ALTER TABLE users ADD COLUMN soft_deleted_at TIMESTAMP NULL;"`
3. `psql -h {host} -U {user} -d {db} -c "CREATE INDEX idx_users_soft_deleted_at ON users(soft_deleted_at) WHERE soft_deleted_at IS NOT NULL;"`
4. `psql -h {host} -U {user} -d {db} -c "COMMIT;"`

### Pre-conditions (verified before execute)
- [ ] Backup `pg_dump > backup-<ISO>.sql` wykonany w ostatnich 60 minutach
- [ ] Migracja przetestowana lokalnie na kopii prod schema
- [ ] Brak aktywnej transakcji blokującej tabelę `users`

### Rollback (jeśli krok ≥2 zawiedzie)
1. `psql -c "ROLLBACK;"`
2. `psql -c "DROP INDEX IF EXISTS idx_users_soft_deleted_at;"`
3. `psql -c "ALTER TABLE users DROP COLUMN IF EXISTS soft_deleted_at;"`
```

**Reguła:** plan zawiera DOSŁOWNIE komendy do uruchomienia — żadnych placeholderów `<TODO>`, żadnej kreatywności „dopiszę w locie".

### Krok 2: Validate

Agent prezentuje plan userowi jako checklist:

```text
> [!danger] FRAGILE OPERATION — wymagana akceptacja każdej komendy

[ ] Komenda 1: `psql -c "BEGIN;"`
[ ] Komenda 2: `psql -c "ALTER TABLE users ADD COLUMN soft_deleted_at TIMESTAMP NULL;"`
[ ] Komenda 3: `psql -c "CREATE INDEX idx_users_soft_deleted_at ..."`
[ ] Komenda 4: `psql -c "COMMIT;"`
[ ] Rollback plan: 3 komendy (patrz wyżej)
[ ] Pre-conditions: 3 sprawdzenia (patrz wyżej)

Odpowiedz: `ACK <komenda-id>` per komenda lub `ACK ALL` dla całości.
Modyfikacja planu → wymagany pełny re-validate.
```

**Wymóg:** user akceptuje LITERALNIE każdą komendę (lub `ACK ALL`). Brak akceptacji → STOP, exit do Phase 5 z plan refinement.

### Krok 3: Execute

Agent uruchamia DOSŁOWNIE zaakceptowane komendy. Reguły:

- **Brak modyfikacji** treści komendy względem zatwierdzonego planu.
- **Brak kreatywności** — jeśli komenda zawiedzie, STOP (nie improwizuj naprawy).
- **Log każdej komendy** — stdout/stderr commitowane do `{baseDir}/docs/fragile-ops/<ISO>-<op-id>.log`.
- **Failure → rollback** — agent uruchamia rollback playbook bez pytania.

---

## 4. Anti-patterns

> [!danger] Zakazane zachowania w fragile zone

| Anti-pattern | Co robi domyślny LLM | Dlaczego źle |
|---|---|---|
| **Zgadywanie nazw kolumn** | „Pewnie kolumna nazywa się `created_at`" | Brak grounding → mismatch → migration fail → potencjalna utrata danych |
| **Refaktor „przy okazji"** | Przy migracji dodaje constraint NOT NULL na innej kolumnie | Łączy 2 zmiany — rollback staje się niedeterministyczny |
| **Łączenie migracji** | „Połączę 3 migracje w jedną dla wydajności" | Każda migracja musi być atomowa; merge łamie historię i rollback per-step |
| **Skipping backup** | „Backup zajmie 20 min, pomijam" | Brak backup'u = brak rollback'u = potencjalna katastrofa |
| **Soft skip dry-run** | „Pominę staging, idę na prod" | Migracja niewalidowana na schema prod → nieznane locki → outage |
| **Modyfikacja komendy w locie** | User zaakceptował `ALTER`, agent dopisał `CASCADE` | Łamie kontrakt Validate gate; każda zmiana = re-validate |

---

## 5. Rollback playbook

> [!important] Każda fragile op MUSI mieć rollback w planie

Wymagania dla sekcji `### Rollback`:

1. **Komendy odwracające** — sekwencja dosłownych komend (nie opis prozą).
2. **Trigger conditions** — jasne kryterium kiedy odpalić (np. „krok 3 zwraca exit ≠ 0").
3. **State checks** — jak zweryfikować, że rollback zadziałał (`SELECT count(*) FROM users WHERE soft_deleted_at IS NOT NULL` = 0).
4. **Communication step** — gdzie zgłosić incydent (np. `#incidents` Slack, on-call rotation).

Przykład:

```text
### Rollback (auto-triggered jeśli execute step ≥2 zwróci exit ≠ 0)

1. Stop: nie uruchamiaj kolejnych kroków planu.
2. Komendy:
   - `psql -c "ROLLBACK;"`  (jeśli w transakcji)
   - `psql -c "DROP INDEX IF EXISTS idx_users_soft_deleted_at;"`
   - `psql -c "ALTER TABLE users DROP COLUMN IF EXISTS soft_deleted_at;"`
3. Verify:
   - `psql -c "\d users"` — kolumna `soft_deleted_at` nie istnieje
   - `psql -c "\di idx_users_soft_deleted_at"` — index nie istnieje
4. Notify: post w `#incidents` z log file path + ISO timestamp.
```

---

## 6. Cytat

> [!quote] since_skill.md §6 — Calibration: kalibracja swobody
> Stopień rygoru zależy od wrażliwości operacji. **Fragile Operations** (migracje DB, zmiany infrastruktury) — agent traci kreatywność, powtarza komendy krok-po-kroku z runbooka. **Plan-Validate-Execute** dla operacji destruktywnych — agent generuje plan, waliduje go z bazą prawdy, dopiero potem wykonuje.

---

## 7. Integracja z fazami

| Faza | Co robi z fragile flag |
|---|---|
| **Phase 0** | Detekcja stref → ustawia `IS_FRAGILE=true/false` (sekcja 2 powyżej) |
| **Phase 4** | Plan dokumentu MUSI zawierać sekcję `### Fragile Operations Plan` z dosłownymi komendami + rollback (sekcja 3 krok 1) |
| **Phase 5** | Approval gate odrzuca plan bez `### Rollback` jeśli `IS_FRAGILE=true` |
| **Phase 6** | Egzekucja w trybie Plan-Validate-Execute (sekcja 3) — agent NIE pisze kreatywnie kodu migracji, kopiuje dosłownie z planu |
| **Phase 7** | Test gate weryfikuje state checks z rollback playbook (sekcja 5 pkt 3) |
