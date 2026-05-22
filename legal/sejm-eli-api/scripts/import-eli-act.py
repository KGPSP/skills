#!/usr/bin/env python3
"""
import-eli-act.py — import metadanych aktu prawnego z api.sejm.gov.pl/eli do Obsidian.

Przykłady:
  import-eli-act.py --vault /path/to/vault DU 2024 1222
  import-eli-act.py --vault /path/to/vault "Dz.U. 2024 poz. 1222"
  import-eli-act.py --vault /path/to/vault --force DU 2024 1222

Vault: --vault albo zmienna środowiskowa OBSIDIAN_VAULT. Brak obu → błąd
(świadomie — żeby nie zapisać notatki w przypadkowym katalogu).

Domyślny output:
  <vault>/PRAWO/akty/<publisher>/<year>/<pos>.md
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.request
from datetime import date
from pathlib import Path
from typing import Any

ELI_BASE = "https://api.sejm.gov.pl/eli"

PUBLISHER_ALIASES = {
    "DZ.U.": "DU",
    "DZ.U": "DU",
    "DZIENNIK USTAW": "DU",
    "DU": "DU",
    "M.P.": "MP",
    "M.P": "MP",
    "MONITOR POLSKI": "MP",
    "MP": "MP",
}


def fetch_json(url: str) -> dict[str, Any] | list[Any]:
    req = urllib.request.Request(
        url,
        headers={"Accept": "application/json", "User-Agent": "eli-obsidian-importer/1.0"},
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            charset = resp.headers.get_content_charset() or "utf-8"
            raw = resp.read().decode(charset, errors="replace")
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")[:1000]
        raise SystemExit(f"ERROR: HTTP {e.code} dla {url}\n{body}") from e
    except urllib.error.URLError as e:
        raise SystemExit(f"ERROR: nie można pobrać {url}: {e}") from e
    try:
        return json.loads(raw)
    except json.JSONDecodeError as e:
        raise SystemExit(f"ERROR: odpowiedź nie jest JSON dla {url}: {e}\n{raw[:1000]}") from e


def yaml_scalar(value: Any) -> str:
    if value is None:
        return '""'
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return str(value)
    s = str(value).replace('"', '\\"')
    return f'"{s}"'


def yaml_list(values: list[Any]) -> str:
    if not values:
        return "[]"
    simple = []
    for v in values:
        if isinstance(v, dict):
            simple.append(yaml_scalar(v.get("id") or v.get("address") or v.get("title")
                                      or json.dumps(v, ensure_ascii=False)))
        else:
            simple.append(yaml_scalar(v))
    return "[" + ", ".join(simple[:30]) + "]"


def slugify_title(title: str, max_len: int = 90) -> str:
    s = re.sub(r"\s+", " ", title).strip()
    s = re.sub(r'[\\/:*?"<>|]+', "-", s)
    return s[:max_len].rstrip(" .-")


def parse_args_to_citation(parts: list[str]) -> tuple[str, int, int]:
    if len(parts) == 3 and parts[1].isdigit() and parts[2].isdigit():
        pub = PUBLISHER_ALIASES.get(parts[0].upper(), parts[0].upper())
        return pub, int(parts[1]), int(parts[2])

    text = " ".join(parts).strip()
    # Dz.U. 2024 poz. 1222 / DU 2024 1222 / M.P. 2025 poz. 10
    m = re.search(
        r"(?i)\b(Dz\.?\s*U\.?|DU|M\.?\s*P\.?|MP|Monitor Polski)\s+"
        r"(?:z\s+dnia\s+)?(\d{4})\s*(?:r\.?\s*)?(?:poz\.?|pozycja)?\s*(\d+)\b",
        text,
    )
    if m:
        pub_raw, year, pos = m.group(1), m.group(2), m.group(3)
        pub_key = re.sub(r"\s+", " ", pub_raw.upper())
        pub = (PUBLISHER_ALIASES.get(pub_key)
               or PUBLISHER_ALIASES.get(pub_key.replace(" ", ""))
               or pub_key)
        return pub, int(year), int(pos)

    m = re.search(r"(?i)\b(DU|MP)/(\d{4})/(\d+)\b", text)
    if m:
        return m.group(1).upper(), int(m.group(2)), int(m.group(3))

    raise SystemExit("ERROR: Nie rozumiem cytowania. Użyj np. `DU 2024 1222` albo `Dz.U. 2024 poz. 1222`.")


def ensure_list(value: Any) -> list[Any]:
    return value if isinstance(value, list) else []


def format_references(refs: Any) -> str:
    if not isinstance(refs, dict) or not refs:
        return "Brak danych w metadanych ELI."
    lines: list[str] = []
    for label, items in refs.items():
        lines.append(f"### {label}")
        lines.append("")
        if not isinstance(items, list) or not items:
            lines.append("- Brak pozycji.")
        else:
            for item in items[:80]:
                if isinstance(item, dict):
                    ident = item.get("id") or item.get("address") or ""
                    when = item.get("date") or item.get("announcementDate") or ""
                    suffix = f" — {when}" if when else ""
                    if ident:
                        lines.append(f"- `{ident}`{suffix}")
                    else:
                        lines.append(f"- `{json.dumps(item, ensure_ascii=False)}`")
                else:
                    lines.append(f"- `{item}`")
        lines.append("")
    return "\n".join(lines).rstrip()


def render_note(meta: dict[str, Any], source_url: str) -> str:
    today = date.today().isoformat()
    publisher = meta.get("publisher") or ""
    year = meta.get("year") or ""
    pos = meta.get("pos") or ""
    title = meta.get("title") or f"{publisher} {year} poz. {pos}"
    display = meta.get("displayAddress") or f"{publisher} {year} poz. {pos}"
    address = meta.get("address") or ""
    keywords = ensure_list(meta.get("keywords"))
    keywords_names = ensure_list(meta.get("keywordsNames"))
    prints = ensure_list(meta.get("prints"))
    directives = ensure_list(meta.get("directives"))

    aliases = [a for a in dict.fromkeys(
        [str(x) for x in (display, address, slugify_title(str(title), 80)) if x]
    )]

    fm = [
        "---",
        f"title: {yaml_scalar(title)}",
        "type: akt-prawny",
        "source: ELI-Sejm",
        f"source_api: {yaml_scalar(source_url)}",
        f"eli_address: {yaml_scalar(address)}",
        f"display_address: {yaml_scalar(display)}",
        f"publisher: {yaml_scalar(publisher)}",
        f"year: {yaml_scalar(year)}",
        f"position: {yaml_scalar(pos)}",
        f"act_type: {yaml_scalar(meta.get('type') or '')}",
        f"status: {yaml_scalar(meta.get('status') or '')}",
        f"in_force: {yaml_scalar(meta.get('inForce') or '')}",
        f"announcement_date: {yaml_scalar(meta.get('announcementDate') or '')}",
        f"promulgation: {yaml_scalar(meta.get('promulgation') or '')}",
        f"entry_into_force: {yaml_scalar(meta.get('entryIntoForce') or '')}",
        f"change_date: {yaml_scalar(meta.get('changeDate') or '')}",
        f"text_html_available: {yaml_scalar(bool(meta.get('textHTML')))}",
        f"text_pdf_available: {yaml_scalar(bool(meta.get('textPDF')))}",
        f"aliases: {yaml_list(aliases)}",
        f"keywords: {yaml_list(keywords)}",
        f"keywords_names: {yaml_list(keywords_names)}",
        "tags: [prawo, eli-sejm, akt-prawny, source/official]",
        f"created: {today}",
        f"updated: {today}",
        'related: ["[[PRAWO/ELI-Sejm]]", "[[PRAWO/INDEX]]"]',
        "---",
    ]

    body = [
        "",
        f"# {display} — {title}",
        "",
        "> Oficjalne metadane pobrane z API ELI Sejmu. Ta notatka rozdziela źródło/metadane od interpretacji prawnej.",
        "",
        "## Metadane",
        "",
        f"- Adres ELI: `{address}`",
        f"- Oznaczenie: **{display}**",
        f"- Typ: **{meta.get('type') or ''}**",
        f"- Status: **{meta.get('status') or ''}** (`{meta.get('inForce') or ''}`)",
        f"- Data ogłoszenia: `{meta.get('announcementDate') or ''}`",
        f"- Promulgacja: `{meta.get('promulgation') or ''}`",
        f"- Wejście w życie: `{meta.get('entryIntoForce') or ''}`",
        f"- Ostatnia zmiana metadanych: `{meta.get('changeDate') or ''}`",
        f"- Tekst HTML dostępny wg metadanych: `{bool(meta.get('textHTML'))}`",
        f"- Tekst PDF dostępny wg metadanych: `{bool(meta.get('textPDF'))}`",
        f"- API: {source_url}",
        "",
    ]

    if keywords or keywords_names:
        body += ["## Słowa kluczowe", ""]
        for kw in keywords:
            body.append(f"- {kw}")
        for kw in keywords_names:
            body.append(f"- {kw}")
        body.append("")

    if prints:
        body += ["## Druki / proces legislacyjny", ""]
        for p in prints:
            if not isinstance(p, dict):
                continue
            num = p.get("number") or ""
            term = p.get("term") or ""
            link_print = p.get("linkPrintAPI") or p.get("link") or ""
            link_process = p.get("linkProcessAPI") or ""
            body.append(f"- Kadencja `{term}`, druk `{num}`")
            if link_print:
                body.append(f"  - Print/API: {link_print}")
            if link_process:
                body.append(f"  - Process/API: {link_process}")
        body.append("")

    if directives:
        body += ["## Akty UE / dyrektywy wskazane w ELI", ""]
        for d in directives[:40]:
            if isinstance(d, dict):
                body.append(f"- `{d.get('address') or ''}` — {d.get('date') or ''} — {d.get('title') or ''}")
        body.append("")

    body += ["## Relacje / references", "", format_references(meta.get("references")), ""]

    body += [
        "## Notatki robocze",
        "",
        "- [ ] Zweryfikować powiązanie z aktywnymi projektami / sprawami.",
        "- [ ] Analizę prawną prowadzić osobno (skill legal/opinie-prawne), nie w tej notatce źródłowej.",
        "- [ ] Przy cytowaniu w pismach sprawdzić aktualność `change_date` i status bezpośrednio w API.",
        "",
        "## Surowe metadane JSON",
        "",
        "```json",
        json.dumps(meta, ensure_ascii=False, indent=2),
        "```",
        "",
    ]
    return "\n".join(fm + body)


def resolve_vault(arg_vault: str | None) -> Path:
    raw = arg_vault or os.environ.get("OBSIDIAN_VAULT")
    if not raw:
        raise SystemExit(
            "ERROR: nie podano vaulta. Użyj --vault <ścieżka> albo ustaw OBSIDIAN_VAULT."
        )
    vault = Path(raw).expanduser().resolve()
    if not vault.exists():
        raise SystemExit(f"ERROR: vault nie istnieje: {vault}")
    return vault


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Importuj akt prawny z api.sejm.gov.pl/eli do vaulta Obsidian"
    )
    parser.add_argument("citation", nargs="+", help="Np. DU 2024 1222 albo 'Dz.U. 2024 poz. 1222'")
    parser.add_argument("--vault", default=None, help="Ścieżka do vaulta (albo OBSIDIAN_VAULT)")
    parser.add_argument("--output-dir", default="PRAWO/akty", help="Katalog docelowy względny wobec vaulta")
    parser.add_argument("--force", action="store_true", help="Nadpisz istniejącą notatkę")
    args = parser.parse_args()

    vault = resolve_vault(args.vault)
    publisher, year, pos = parse_args_to_citation(args.citation)
    url = f"{ELI_BASE}/acts/{publisher}/{year}/{pos}"
    data = fetch_json(url)
    if not isinstance(data, dict):
        raise SystemExit(f"ERROR: oczekiwano obiektu JSON, otrzymano {type(data).__name__}")

    out = vault / args.output_dir / publisher / str(year) / f"{pos}.md"
    out.parent.mkdir(parents=True, exist_ok=True)
    if out.exists() and not args.force:
        raise SystemExit(f"ERROR: plik już istnieje: {out}\nUżyj --force, aby nadpisać.")

    out.write_text(render_note(data, url), encoding="utf-8")

    print(json.dumps({
        "ok": True,
        "publisher": publisher,
        "year": year,
        "position": pos,
        "displayAddress": data.get("displayAddress"),
        "title": data.get("title"),
        "status": data.get("status"),
        "inForce": data.get("inForce"),
        "output": str(out),
        "source_api": url,
    }, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
