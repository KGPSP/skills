---
name: endpoints
type: reference
parent: sejm-eli-api
sources:
  - DOC/since_skill.md   # §5 Progressive Disclosure — ciężki katalog poza SKILL.md
  - DOC/material_skill.md # §3 Verification — grunt w realnym źródle, nie mock
description: Zweryfikowany katalog endpointów api.sejm.gov.pl/eli — wzorce ścieżek, parametry, kształt odpowiedzi. Załaduj gdy potrzebujesz parametrów wyszukiwarki, pełnej listy pól lub chcesz dodać/zweryfikować endpoint.
load-when: Faza 1/2/4 SKILL.md — potrzebne parametry wyszukiwarki, pełna lista pól metadanych, struktura struct/references, albo weryfikacja nowego endpointu.
---

# Sejm ELI API — katalog endpointów

Baza: `https://api.sejm.gov.pl/eli`. Wszystkie ścieżki poniżej **zweryfikowano `curl`-em 2026-05-22** (kod 200). Standard danych: ELI (European Legislation Identifier). Brak OpenAPI/Swagger — ten plik jest dokumentacją zastępczą. **Dodawaj wyłącznie endpointy potwierdzone w sesji.**

## Reguła rozszerzania

Zanim dopiszesz endpoint do tego pliku:
```sh
curl -sS -o /dev/null -w '%{http_code} %{content_type}\n' --max-time 20 "<URL>"
```
Dopisz tylko przy `200` + odnotuj datę weryfikacji.

## 1. `GET /acts` — lista publikatorów

Zwraca listę obiektów:

| Pole | Przykład | Znaczenie |
|------|----------|-----------|
| `code` | `DU` | kod publikatora (używany w ścieżkach) |
| `name` | `Dziennik Ustaw` | nazwa pełna |
| `shortName` | `Dz.U.` | skrót cytowania |
| `actsCount` | `97249` | liczba aktów |
| `years` | `[1918, …, 2026]` | dostępne roczniki |

Kody w użyciu: **`DU`** (Dziennik Ustaw), **`MP`** (Monitor Polski). Inne odczytaj z tego endpointu — nie zakładaj.

## 2. `GET /acts/{publisher}/{year}` — lista aktów w roczniku

Zwraca metadane wszystkich aktów danego publikatora w roku. Użyteczne do przeglądu/filtrowania po `pos`.

## 3. `GET /acts/{publisher}/{year}/{position}` — metadane aktu (rdzeń)

Przykład: `/acts/DU/2024/1222`. Pola obserwowane:

| Pole | Przykład | Uwaga |
|------|----------|-------|
| `address` | `WDU20240001222` | adres ELI (wewnętrzny) |
| `displayAddress` | `Dz.U. 2024 poz. 1222` | cytowanie do prezentacji |
| `ELI` | `pl/2024/1222/...` | identyfikator ELI (gdy obecny) |
| `title` | `Ustawa z dnia 12 lipca 2024 r. …` | pełny tytuł |
| `type` | `Ustawa` | rodzaj aktu |
| `status` | `obowiązujący` | status słowny |
| `inForce` | `IN_FORCE` | status maszynowy |
| `announcementDate` | `2024-07-12` | data ogłoszenia |
| `promulgation` | `2024-08-09` | data promulgacji |
| `entryIntoForce` | `2024-11-10` | wejście w życie |
| `changeDate` | `2026-03-24T17:04:24` | **świeżość metadanych** |
| `textHTML` / `textPDF` | `true` | dostępność treści (sprawdź PRZED pobraniem) |
| `keywords` / `keywordsNames` | `[…]` | słowa kluczowe |
| `prints` | `[{term, number, linkPrintAPI, linkProcessAPI}]` | kontekst legislacyjny |
| `directives` | `[…]` | wskazane dyrektywy UE |
| `references` | `{…}` | relacje (patrz §6) |

## 4. `GET /acts/{publisher}/{year}/{position}/text.html` — treść HTML

`200 text/html;charset=utf-8`. Pobieraj tylko gdy metadane `textHTML:true`. Źródło literalnego brzmienia do cytowania.

## 5. `GET /acts/{publisher}/{year}/{position}/text.pdf` — treść PDF

`200 application/pdf`. Pobieraj tylko gdy `textPDF:true`. Do pobrania binarnego użyj `curl -o plik.pdf`.

## 6. `GET /acts/{publisher}/{year}/{position}/struct` — spis treści

Lista hierarchiczna jednostek redakcyjnych. Węzeł:
```json
{"id": "chpt_1-arti_1", "symbol": "arti_1", "type": "arti", "name": "1", "title": "Art. 1.", "children": [ … ]}
```
Typy węzłów: `part` (część), `chpt` (rozdział), `arti` (artykuł), `pint`/`point` (punkt), itd. Użyteczne do nawigacji po konkretnej jednostce redakcyjnej.

## 7. `GET /acts/{publisher}/{year}/{position}/references` — relacje

JSON z relacjami między aktami. Klucze obserwowane:
`Akty uchylone`, `Akty uznane za uchylone`, `Akty wykonawcze`, `Akty zmieniające`, `Akty zmienione`, `Przepisy wprowadzane`. (Te same dane bywają zagnieżdżone w polu `references` metadanych z §3.)

## 8. `GET /acts/search` — wyszukiwarka

Parametry (potwierdzone): `title`, `limit`, `offset`. Odpowiedź:

```json
{ "count": 2, "totalCount": 37, "offset": 0, "searchQuery": {…}, "items": [ … ] }
```

- `totalCount` — liczba wszystkich trafień; paginuj `offset` o `limit`.
- `items[]` — bogate metadane (te same pola co §3 + `volume`, `texts`, `authorizedBody`, `releasedBy`, `obligated`, `previousTitle`).

Inne parametry (np. `keyword`, `type`, `year`, `pubDateFrom/To`) mogą być wspierane — **zweryfikuj `curl`-em** zanim użyjesz w przepływie.

## Caveaty operacyjne

- Zawsze `--max-time` na curl (np. 25 s) — unikaj zawieszenia.
- Cytując dane, podawaj `source_api` (pełny URL) — audytowalność.
- Kod ≠ 200 → traktuj jako brak danych; zgłoś kod, nie zgaduj.
