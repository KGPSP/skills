#!/bin/sh
# check-cost-plan.sh — walidator kompletności raport.md (skill: planowanie-wydatkow-it-psp)
#
# Klasyfikacja UFP 2027+ wg Dz.U. 2026 poz. 582 (rozp. MFiG z 20.04.2026).
# Paragrafy 3-cyfrowe (682, 702, 704, 711, 712, 720, 778, ...) zamiast 4-cyfrowych
# legacy (4xxx/6xxx). Próg 10 000 zł zlikwidowany — polityka rachunkowości decyduje.
#
# Sprawdza:
#   1. Brak paragrafów 4-cyfrowych legacy (4xxx/6xxx) w sekcji tabeli XLSX i tabeli III.B.
#      Stara klasyfikacja do 2026 — nieaktualna dla planowania 2027+.
#   2. Kurs planistyczny z datą (regex: "Kurs planistyczny: 1 [A-Z]+ = ").
#   3. Każda pozycja w tabeli XLSX ma odpowiadającą sekcję uzasadnienia z 8 punktami
#      (tryb A/B). Dla trybu C — 4 punkty (2, 5, 7, 8).
#   4. Każda pozycja > 100 000 zł brutto ma sekcję "Wniosek o opinię MSWiA".
#   5. Każda pozycja w paragrafie majątkowym 700–729 (701/702/703/704/711/712/720) ma frazę
#      "Plan utrzymania" / "5 lat" / "pkt 184".
#   6. Każda pozycja walutowa (USD/EUR/GBP/CHF) ma wzmiankę o reverse charge / VAT.
#   7. Tryb A → klasyfikacja 752/75282 obecna.
#   8. Tabela XLSX: dla każdego wiersza suma kolumn G..L = kolumna F (alokacja per jednostka PSP).
#   9. § 704 (specjalistyczny sprzęt bezpieczeństwa publicznego) wymaga uzasadnienia operacyjnego
#      — frazy "zadanie operacyjne" / "sprzęt specjalistyczny" / "dyspozytorski" /
#      "łączność krytyczna" / "system ratowniczy" / "operacyjne PSP" w pliku raportu.
#
# Exit codes:
#   0 — wszystko OK.
#   1 — co najmniej jeden błąd (komunikat na stderr).
#   2 — błędne wywołanie (brak argumentu --plan).
#
# Zgodny z POSIX shell (sh). Bez bashizmów.

set -eu

PROG="$(basename "$0")"
PLAN=""
TRYB="A"  # domyślnie POLiOC cz. 42 obronne; opcjonalnie --tryb C dla skróconego schematu

usage() {
    cat >&2 <<EOF
Użycie: $PROG --plan <ścieżka-do-raport.md> [--tryb A|B|C]

  --plan   ścieżka do pliku raport-<system>-<RRRR-MM-DD>.md (wymagane)
  --tryb   tryb klasyfikacji: A (POLiOC obronne 752/75282) | B (POLiOC podstawowy 754/75414) | C (środki własne 754/75409)
           domyślnie: A. Tryb C ma skrócony schemat uzasadnienia (4 pkt zamiast 8).

Klasyfikacja UFP 2027+ (Dz.U. 2026 poz. 582). Paragrafy 3-cyfrowe.

Exit codes: 0=OK, 1=błąd walidacji, 2=błędne wywołanie.
EOF
    exit 2
}

# parsowanie argumentów
while [ $# -gt 0 ]; do
    case "$1" in
        --plan)
            [ $# -ge 2 ] || usage
            PLAN="$2"
            shift 2
            ;;
        --tryb)
            [ $# -ge 2 ] || usage
            TRYB="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            printf '%s: nieznany argument: %s\n' "$PROG" "$1" >&2
            usage
            ;;
    esac
done

[ -n "$PLAN" ] || usage

if [ ! -f "$PLAN" ]; then
    printf '%s: plik nie istnieje: %s\n' "$PROG" "$PLAN" >&2
    exit 2
fi

case "$TRYB" in
    A|B|C) : ;;
    *)
        printf '%s: nieznany tryb: %s (dozwolone: A, B, C)\n' "$PROG" "$TRYB" >&2
        usage
        ;;
esac

ERRORS=0

err() {
    printf '✘ %s\n' "$1" >&2
    ERRORS=$((ERRORS + 1))
}

ok() {
    printf '✔ %s\n' "$1"
}

printf '== Walidacja raport.md: %s (tryb %s, klasyfikacja 2027+) ==\n' "$PLAN" "$TRYB"

# Sprawdzenie 1: brak paragrafów 4-cyfrowych legacy (4xxx/6xxx)
# Heurystyka: szukamy w kolumnach paragrafu (po znaku |) liczb 4-cyfrowych zaczynających się od 4 lub 6
# oraz wzorca "§ 4xxx" / "§ 6xxx" w tekście. Wyłączamy 4-cyfrowe rozdziały (754xx, 752xx).
LEGACY_FOUND=0
# Wzorzec 1: "§ NNNN" gdzie NNNN to 4-cyfrowy zaczynający się od 4 lub 6
if grep -qE '§[[:space:]]*[46][0-9]{3}\b' "$PLAN"; then
    LEGACY_FOUND=1
fi
# Wzorzec 2: kolumna z paragrafem (otoczona |...|) zawierająca 4-cyfrową liczbę [46]xxx
# Wyłączamy zakresy rozdziałów (75XXX) — szukamy paragrafów 4-cyfrowych w kolumnach o szerokości <10 znaków
if awk -F'|' '
    /^[[:space:]]*\|/ {
        for (i = 1; i <= NF; i++) {
            v = $i; gsub(/[[:space:]]/, "", v)
            if (v ~ /^[46][0-9]{3}$/) { found=1; exit }
        }
    }
    END { exit (found ? 0 : 1) }
' "$PLAN"; then
    LEGACY_FOUND=1
fi
if [ "$LEGACY_FOUND" -eq 1 ]; then
    err "Znaleziono paragraf 4-cyfrowy LEGACY (4xxx/6xxx) — klasyfikacja do 2026, nieaktualna dla planowania 2027+. Zastąp paragrafem 3-cyfrowym wg Dz.U. 2026 poz. 582: 682 (usługi IT), 681 (telekom), 631 (dzierżawa), 677 (ekspertyzy), 638 (szkolenia), 670 (zlecenia), 770/771 (energia/woda), 778 (materiały), 701/702/704 (ŚT), 711/712 (WNiP), 720 (inwestycje). Klucz przejścia: references/klasyfikacja-budzetowa.md §10."
    grep -nE '§[[:space:]]*[46][0-9]{3}\b' "$PLAN" 2>/dev/null | head -5 >&2 || true
else
    ok "Brak paragrafów 4-cyfrowych legacy (4xxx/6xxx)."
fi

# Sprawdzenie 2: kurs planistyczny z datą
if grep -qE 'Kurs planistyczny: 1 [A-Z]+ = [0-9]+([,.][0-9]+)? PLN.*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$PLAN"; then
    ok "Kurs planistyczny NBP z datą obecny."
else
    if grep -qE '\b(USD|EUR|GBP|CHF)\b' "$PLAN"; then
        err "Brak kursu planistycznego z datą, mimo obecności pozycji walutowych (USD/EUR/GBP/CHF). Wymagany format: 'Kurs planistyczny: 1 USD = X,XX PLN (NBP, RRRR-MM-DD)'."
    else
        ok "Brak pozycji walutowych — kurs planistyczny niewymagany."
    fi
fi

# Sprawdzenie 3: 8-punktowe uzasadnienie (tryb A/B) lub 4-punktowe (C)
case "$TRYB" in
    A|B)
        REQUIRED_POINTS="1. KWALIFIKOWALNOŚĆ
2. CELOWOŚĆ
3. ZGODNOŚĆ
4. LOKALIZACJA
5. KOSZTORYS
6. WSKAŹNIK
7. OKRES
8. PRÓG"
        EXPECTED_COUNT=8
        ;;
    C)
        REQUIRED_POINTS="2. CELOWOŚĆ
5. KOSZTORYS
7. OKRES
8. PRÓG"
        EXPECTED_COUNT=4
        ;;
esac

POZYCJE=$(grep -cE '^## Pozycja:' "$PLAN" || true)
if [ "$POZYCJE" -eq 0 ]; then
    err "Brak sekcji '## Pozycja:' w raport.md. Każda pozycja XLSX musi mieć odpowiadającą sekcję uzasadnienia."
else
    ok "Znaleziono $POZYCJE sekcji '## Pozycja:'."

    OLD_IFS=$IFS
    IFS='
'
    for point in $REQUIRED_POINTS; do
        [ -z "$point" ] && continue
        COUNT=$(grep -cE "^### $point" "$PLAN" 2>/dev/null || true)
        if [ "$COUNT" -lt "$POZYCJE" ]; then
            err "Punkt '$point' występuje $COUNT razy, oczekiwano $POZYCJE (po jednym per pozycja)."
        fi
    done
    IFS=$OLD_IFS
fi

# Sprawdzenie 4: pozycje > 100 000 zł brutto mają wniosek o opinię MSWiA
# tr -d ' *' usuwa też markdownowe ** wokół "**Kwota brutto PLN:**"
KWOTY_OVER_100K=$(grep -E 'Kwota brutto PLN:' "$PLAN" 2>/dev/null | tr -d ' *' | grep -cE 'KwotabruttoPLN:[0-9]{6,}' || true)
if [ "$KWOTY_OVER_100K" -gt 0 ]; then
    if grep -qiE '(opinię MSWiA|opinii MSWiA|wniosek-opinii-)' "$PLAN"; then
        ok "Pozycje > 100 000 zł brutto ($KWOTY_OVER_100K szt.) mają odniesienie do opinii MSWiA."
    else
        err "Pozycje > 100 000 zł brutto ($KWOTY_OVER_100K szt.), ale brak odniesienia do 'opinię MSWiA' lub 'wniosek-opinii-' w raport.md. Pkt 166 Programu wymaga opinii."
    fi
fi

# Sprawdzenie 5: pozycje w paragrafach majątkowych 2027+ (700-729) mają plan utrzymania ≥ 5 lat
# Wzorzec: § 701 / 702 / 703 / 704 / 711 / 712 / 720 / 721 itd.
if grep -qE '§[[:space:]]*7[012][0-9]\b|\|[[:space:]]*7[012][0-9][[:space:]]*\|' "$PLAN"; then
    if grep -qiE '(5 lat|≥ 5 lat|>= 5 lat|pi[ęe][cć] lat|pkt 184)' "$PLAN"; then
        ok "Pozycje majątkowe (§ 700–729) mają odniesienie do planu utrzymania ≥ 5 lat."
    else
        err "Pozycje majątkowe (paragrafy 700–729: 701/702/703/704/711/712/720) obecne, ale brak frazy '5 lat' / 'pkt 184'. Wymóg pkt 184 Projektu Programu OLiOC 2027–2031."
    fi
fi

# Sprawdzenie 6: pozycje walutowe (USD/EUR) mają wzmiankę o reverse charge lub VAT
if grep -qE '\b(USD|EUR|GBP|CHF)\b' "$PLAN"; then
    if grep -qiE '(reverse charge|RC 23%|import usług|art\. 17 ust\. 1 pkt 4)' "$PLAN"; then
        ok "Pozycje walutowe mają wzmiankę o reverse charge / VAT."
    else
        err "Pozycje walutowe (USD/EUR) obecne, ale brak wzmianki o reverse charge / RC 23% / import usług. Art. 17 ust. 1 pkt 4 ustawy o VAT."
    fi
fi

# Sprawdzenie 7: tryb A — klasyfikacja 752/75282
if [ "$TRYB" = "A" ]; then
    if grep -qE '\b75282\b' "$PLAN" && grep -qE '\b752\b' "$PLAN"; then
        ok "Tryb A — klasyfikacja 752/75282 obecna."
    else
        err "Tryb A (POLiOC cz. 42 obronne), ale brak klasyfikacji 752 lub 75282 w raport.md. Cz. IX.2."
    fi
fi

# Sprawdzenie 8: tabela XLSX — suma kolumn G..L = F dla każdego wiersza
SUMA_OUTPUT=$(awk -F'|' '
    /^[[:space:]]*\|/ {
        if (NF != 14) next
        for (i = 1; i <= NF; i++) gsub(/^[[:space:]]+|[[:space:]]+$/, "", $i)
        if ($2 ~ /^[-:]+$/) next
        f_str = $7; gsub(/[[:space:]]/, "", f_str)
        if (f_str !~ /^[0-9]+$/) next
        suma = 0; valid = 1
        for (i = 8; i <= 13; i++) {
            v = $i; gsub(/[[:space:]]/, "", v)
            if (v !~ /^[0-9]+$/) { valid = 0; break }
            suma += v
        }
        if (!valid) next
        rows++
        f_num = f_str + 0
        if (suma != f_num) {
            bad_rows++
            printf "  wiersz %d (\"%s\"): F=%d, suma G..L=%d, różnica=%d\n", NR, $3, f_num, suma, f_num - suma
        }
    }
    END {
        printf "ROWS=%d\nBAD=%d\n", rows + 0, bad_rows + 0
    }
' "$PLAN")

SUMA_ROWS=$(printf '%s\n' "$SUMA_OUTPUT" | sed -n 's/^ROWS=//p')
SUMA_BAD=$(printf '%s\n' "$SUMA_OUTPUT" | sed -n 's/^BAD=//p')
SUMA_DETAILS=$(printf '%s\n' "$SUMA_OUTPUT" | grep -v '^ROWS=' | grep -v '^BAD=' || true)

if [ "${SUMA_ROWS:-0}" -eq 0 ]; then
    err "Brak wierszy tabeli XLSX (12 kolumn) z kwotą numeryczną w kolumnie F. Sekcja 7 raport.md wymaga tabeli w układzie A..L wg templates/tabela-xlsx-uklad.md."
elif [ "${SUMA_BAD:-0}" -gt 0 ]; then
    err "Tabela XLSX: $SUMA_BAD z $SUMA_ROWS wierszy ma sum(G..L) ≠ F (alokacja per jednostka PSP nie zgadza się z kwotą brutto). Cz. X.6."
    [ -n "$SUMA_DETAILS" ] && printf '%s\n' "$SUMA_DETAILS" >&2
else
    ok "Tabela XLSX: $SUMA_ROWS wierszy — sum(G..L) = F dla każdego."
fi

# Sprawdzenie 9: § 704 (specjalistyczny sprzęt bezpieczeństwa publicznego) wymaga uzasadnienia operacyjnego
# § 704 jest zarezerwowany dla sprzętu do zadań operacyjnych PSP (dyspozytorski, łączność krytyczna,
# zintegrowany z systemami ratowniczymi). Sprzęt administracyjny → § 702.
if grep -qE '§[[:space:]]*704\b|\|[[:space:]]*704[[:space:]]*\||\b704001\b' "$PLAN"; then
    if grep -qiE '(zadanie operacyjne|sprzęt specjalistyczny|dyspozytorski|łączność krytyczna|system ratowniczy|operacyjne PSP|zintegrowan[ye] z systemami ratowniczymi)' "$PLAN"; then
        ok "Pozycje § 704 mają uzasadnienie operacyjne (sprzęt specjalistyczny PSP)."
    else
        err "Pozycje § 704 (specjalistyczny sprzęt bezpieczeństwa publicznego) obecne, ale brak uzasadnienia operacyjnego. Wymagane frazy w raport.md: 'zadanie operacyjne' / 'sprzęt specjalistyczny' / 'dyspozytorski' / 'łączność krytyczna' / 'system ratowniczy' / 'operacyjne PSP'. BIŁ KG PSP ostrzega: serwer administracyjny ujęty w 704001 bez uzasadnienia = błąd kontrolny. Patrz references/klasyfikacja-budzetowa.md §6/Pułapka 8."
    fi
fi

printf '== Podsumowanie: %d błędów ==\n' "$ERRORS"

if [ "$ERRORS" -eq 0 ]; then
    printf '✔ all checks passed\n'
    exit 0
else
    printf '✘ FAILED: %d błędów. Popraw raport.md i uruchom ponownie.\n' "$ERRORS" >&2
    exit 1
fi
