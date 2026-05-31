# Plan fixture — check-ac-coverage Phase 4 / ac-protocol matrix

## Co i dlaczego

Regression fixture dla `check-ac-coverage.sh` (bug format-drift wykryty w e2e 2026-05-31):
format zgodny z ac-protocol.md / SKILL.md Phase 4 — **Test ID = kolumna 5, Plik testu = kolumna 6**,
AC-ID typu `AC-F-01`. PRZED fixem skrypt: (a) regex `AC-[FNC]` nie łapał `AC-1`, (b) czytał
test_file z kol. 5 (=Test ID) → `file_missing`. PO fixie → `status:ok`.

## Acceptance Criteria

| AC-ID | Typ (F/N/C) | Opis | Test ID | Plik testu | Komenda |
|---|---|---|---|---|---|
| AC-F-01 | F | add zwraca sumę | T-1 | tests/fixtures/ac-coverage-tests/calc.test.js | npm test |
| AC-N-02 | N | perf <100ms (z sufiksem :LINE) | T-2 | tests/fixtures/ac-coverage-tests/calc.test.js:7 | npm test |
