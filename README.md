# KGPSP Skills

Zbiór wyspecjalizowanych **Claude Code Skills** używanych w Komendzie Głównej Państwowej Straży Pożarnej. Skille są zorganizowane w kategorie tematyczne; każdy skill to samodzielny folder z plikiem `SKILL.md` (frontmatter + instrukcje) oraz katalogami pomocniczymi (`templates/`, `references/`, `scripts/`, `agents/`).

## Struktura

```
skills/
├── pzp/      # Prawo Zamówień Publicznych
├── legal/    # Opinie prawne i analizy normatywne
└── dev/      # Narzędzia developerskie (planowanie, implementacja)
```

## Katalog skilli

### `pzp/` — Prawo Zamówień Publicznych

| Skill | Zastosowanie |
|-------|--------------|
| [`analyzing-pzp-offers`](pzp/analyzing-pzp-offers/) | Weryfikacja oferty wykonawcy w postępowaniu PZP (oferta vs SWZ/OPZ + pisma/modyfikacje). Produkuje raport z cytatami źródeł i indeksem dokumentów. |
| [`drafting-pzp-letters`](pzp/drafting-pzp-letters/) | Projekty pism proceduralnych (wezwania do uzupełnienia/wyjaśnień, informacje o odrzuceniu/wykluczeniu, zawiadomienia o poprawie omyłki, wybór/unieważnienie) na podstawie analizy oferty. Generuje `.md` + `.docx` w szablonie EZD. |
| [`weryfikacja-umow-pzp`](pzp/weryfikacja-umow-pzp/) | Audyt projektu umowy / PPU przed podpisaniem — z parą **cytat obecnego brzmienia + proponowane brzmienie** dla każdej wykrytej wady. |
| [`odpowiedzi-pytania`](pzp/odpowiedzi-pytania/) | Odpowiedzi Zamawiającego na pytania wykonawców (wyjaśnienia/modyfikacje SWZ) — model 3 hipotez, finalne odpowiedzi do publikacji, raport ryzyk. |

### `legal/` — Opinie prawne

| Skill | Zastosowanie |
|-------|--------------|
| [`opinie-prawne`](legal/opinie-prawne/) | Sporządzanie opinii prawnych w polskim porządku prawnym (effort max, deep research po isap.sejm.gov.pl, eli.gov.pl, orzecznictwo SN/NSA/TK). |

### `dev/` — Narzędzia developerskie

| Skill | Zastosowanie |
|-------|--------------|
| [`feature-planner`](dev/feature-planner/) | Strukturalny workflow implementacji feature'a (Replit Agent style) z auto Agent Teams routing, `/effort max`, deep-research probe. Pełen cykl: analyze → hypothesize → plan → approval gate → implement → test → review → ADR. |
| [`feature-planner-codex`](dev/feature-planner-codex/) | Wariant Codex-native (bez Claude-Code-specific koncepcji typu Agent Teams, slash commands). Przeznaczony do pracy w Codex CLI. |

## Użycie

Skille są przeznaczone do pracy w **Claude Code** (CLI / IDE). Po sklonowaniu repo wskaż katalog jako źródło skilli — Claude Code automatycznie odczyta frontmatter `name` / `description` z każdego `SKILL.md`.

Trigger skilla z poziomu czatu:

```
/<nazwa-skilla>
```

lub naturalnym językiem zgodnym z `description` w SKILL.md.

## Konwencje

- Każdy skill jest **samodzielny** — wszystkie wymagane templates/references/scripts znajdują się w jego folderze.
- Skille operacyjne (PZP, legal) generują artefakty w **Obsidian Flavored Markdown** z frontmatterem YAML, gotowe do zapisu w vaulcie KG PSP.
- Skille developerskie (`dev/`) zakładają pracę w repozytorium git z konwencjami `docs/plany/`, `docs/adr/`.

## Licencja

Wewnętrzny użytek KG PSP. Treść skilli odzwierciedla praktykę i metodykę pracy KG PSP — wykorzystanie poza organizacją wymaga uzgodnienia.
