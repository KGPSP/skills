# sejm-eli-api

Skill Claude Code do **komunikacji z urzędowym źródłem prawa RP** przez oficjalne API Sejmu oparte o standard ELI: `https://api.sejm.gov.pl/eli`.

To **warstwa pozyskania i ugruntowania (retrieval/grounding)** — dostarcza maszynowo czytelne, urzędowe metadane aktów prawnych (status, daty, relacje, spis treści, treść HTML/PDF) oraz wyszukiwanie i import do Obsidian. **Nie** prowadzi wykładni ani nie sporządza opinii — od tego jest [`legal/opinie-prawne`](../opinie-prawne/) (ten skill bywa jego fazą deep-research: pozyskanie literalnego brzmienia).

## Kiedy się aktywuje

- „sprawdź akt w ELI", „pobierz metadane Dz.U.", „jaki status ma ustawa / czy obowiązuje"
- cytowania `Dz.U. <rok> poz. <nr>` / `M.P. <rok> poz. <nr>`
- „znajdź akt po tytule", „pobierz treść / spis treści aktu", „zweryfikuj cytat względem źródła"
- „importuj akt do Obsidian"

## Zawartość

```
sejm-eli-api/
├── SKILL.md                       # procedura (6 faz + exit criteria), anti-rationalization, DoD
├── references/
│   ├── endpoints.md               # zweryfikowany katalog endpointów (2026-05-22)
│   └── obsidian-import.md         # format notatki + opcje importera
└── scripts/
    ├── eli-fetch.sh               # POSIX wrapper: publishers/search/year/meta/struct/references/text
    └── import-eli-act.py          # import metadanych aktu → notatka Obsidian
```

## Szybki start

```sh
# metadane aktu
scripts/eli-fetch.sh meta DU 2024 1222

# wyszukanie po tytule
scripts/eli-fetch.sh search "Prawo zamówień publicznych" 5

# import do vaulta Obsidian (vault podaje użytkownik)
scripts/import-eli-act.py --vault /ścieżka/do/vaulta DU 2024 1222
```

## Źródło prawdy / pryncypia

Zbudowany wg pryncypiów `DOC/` (Process over Prose, Anti-Rationalization, DoD = dowód, Progressive Disclosure, Negative Triggers). Endpointy zweryfikowane `curl`-em — patrz `references/endpoints.md`.
