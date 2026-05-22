---
name: obsidian-import
type: reference
parent: sejm-eli-api
sources:
  - DOC/since_skill.md    # §5 scripts/ jako narzędzia deterministyczne; §6 brak ścieżek absolutnych
  - DOC/material_skill.md # §8 Scope Discipline — zapis tylko na żądanie, jawny --vault
description: Format notatki Obsidian generowanej z metadanych ELI + opcje importera. Załaduj w Fazie 6 (import do vaulta).
load-when: Faza 6 SKILL.md — materializacja aktu jako notatki Obsidian.
---

# ELI → Obsidian — format importu

Skrypt: [`scripts/import-eli-act.py`](../scripts/import-eli-act.py). Pobiera metadane z `GET /acts/{pub}/{year}/{pos}` i zapisuje notatkę Markdown z frontmatterem źródłowym.

## Uruchomienie

```sh
# z trójki cytowania
scripts/import-eli-act.py --vault "<ścieżka-vaulta>" DU 2024 1222

# z surowego cytowania
scripts/import-eli-act.py --vault "<ścieżka-vaulta>" "Dz.U. 2024 poz. 1222"

# nadpisanie istniejącej notatki
scripts/import-eli-act.py --vault "<ścieżka-vaulta>" --force DU 2024 1222

# alternatywny katalog docelowy (względny wobec vaulta)
scripts/import-eli-act.py --vault "<vault>" --output-dir PRAWO/akty DU 2024 1222
```

**`--vault` jest wymagane przez użytkownika.** Skrypt może też odczytać zmienną środowiskową `OBSIDIAN_VAULT`, jeśli `--vault` pominięto. Brak obu → błąd (świadomie — żeby nie zapisać „na ślepo" w przypadkowym katalogu).

## Ścieżka docelowa

```text
<vault>/PRAWO/akty/<publisher>/<year>/<position>.md
# np. PRAWO/akty/DU/2024/1222.md
```

## Pola frontmatter notatki

| Pole | Źródło (pole API) |
|------|-------------------|
| `title` | `title` |
| `type` | stałe `akt-prawny` |
| `source` | stałe `ELI-Sejm` |
| `source_api` | URL wywołania |
| `eli_address` | `address` |
| `display_address` | `displayAddress` |
| `publisher` / `year` / `position` | `publisher` / `year` / `pos` |
| `act_type` | `type` |
| `status` / `in_force` | `status` / `inForce` |
| `announcement_date` | `announcementDate` |
| `promulgation` | `promulgation` |
| `entry_into_force` | `entryIntoForce` |
| `change_date` | `changeDate` |
| `text_html_available` / `text_pdf_available` | `textHTML` / `textPDF` |
| `keywords` / `keywords_names` | `keywords` / `keywordsNames` |
| `aliases` | `displayAddress`, `address`, slug tytułu |
| `created` / `updated` | data importu |

Body notatki zawiera: sekcję metadanych, słowa kluczowe, druki/proces legislacyjny (`prints`), dyrektywy UE (`directives`), relacje (`references`), notatki robocze oraz **surowy blok JSON** metadanych (audytowalność).

## Zasady

- **Rozdzielaj źródło od interpretacji:** notatka to metadane + surowe dane. Analizę prawną prowadź w osobnej notatce / przez `legal/opinie-prawne`.
- **Linkowanie:** notatka linkuje do MOC-ów `[[PRAWO/ELI-Sejm]]`, `[[PRAWO/INDEX]]` (dostosuj do swojego vaulta).
- **Świeżość:** przy ponownym imporcie używaj `--force`; pole `change_date` pokazuje, czy metadane się zmieniły.
- **Bez ścieżek absolutnych w skillu:** vault podaje użytkownik (`--vault`/`OBSIDIAN_VAULT`), nie jest zaszyty w kodzie.
