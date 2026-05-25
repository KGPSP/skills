#!/bin/sh
# check-cost-plan.sh — walidator kompletności raport.md (skill: planowanie-wydatkow-it-psp)
#
# Sprawdza:
#   1. Brak § 4000 w sekcji tabeli XLSX i tabeli III.B.
#   2. Kurs planistyczny z datą (regex: "Kurs planistyczny: 1 [A-Z]+ = ").
#   3. Każda pozycja w tabeli XLSX ma odpowiadającą sekcję uzasadnienia z 8 punktami
#      (tryb A/B). Dla trybu C — 4 punkty (2, 5, 7, 8).
#   4. Każda pozycja > 100 000 zł brutto ma sekcję "Wniosek o opinię MSWiA".
#   5. Każda pozycja w § 6050 lub § 6060 ma frazę "Plan utrzymania" i "5 lat".
#   6. Każda pozycja walutowa (USD/EUR/GBP/CHF) ma wzmiankę o reverse charge / VAT.
#   7. Tryb A → klasyfikacja 752/75282 obecna.
#   8. Tabela XLSX: dla każdego wiersza suma kolumn G..L = kolumna F (alokacja per jednostka PSP).
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

printf '== Walidacja raport.md: %s (tryb %s) ==\n' "$PLAN" "$TRYB"

# Sprawdzenie 1: brak § 4000
if grep -qE '§[[:space:]]*4000\b|^\|[[:space:]]*4000[[:space:]]*\||\b4000\b[[:space:]]*\|' "$PLAN"; then
    err "Znaleziono § 4000 (placeholder, NIE pozycja klasyfikacji). Zastąp szczegółowym (4210/4260/4300/4350/4360/4390/4700) wg references/klasyfikacja-budzetowa.md §6."
    grep -nE '§[[:space:]]*4000\b|^\|[[:space:]]*4000[[:space:]]*\||\b4000\b[[:space:]]*\|' "$PLAN" | head -5 >&2
else
    ok "Brak § 4000 (placeholder)."
fi

# Sprawdzenie 2: kurs planistyczny z datą
if grep -qE 'Kurs planistyczny: 1 [A-Z]+ = [0-9]+([,.][0-9]+)? PLN.*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$PLAN"; then
    ok "Kurs planistyczny NBP z datą obecny."
else
    # Sprawdź czy w ogóle są pozycje walutowe — jeśli nie, kurs nie jest wymagany
    if grep -qE '\b(USD|EUR|GBP|CHF)\b' "$PLAN"; then
        err "Brak kursu planistycznego z datą, mimo obecności pozycji walutowych (USD/EUR/GBP/CHF). Wymagany format: 'Kurs planistyczny: 1 USD = X,XX PLN (NBP, RRRR-MM-DD)'."
    else
        ok "Brak pozycji walutowych — kurs planistyczny niewymagany."
    fi
fi

# Sprawdzenie 3: 8-punktowe uzasadnienie (tryb A/B) lub 4-punktowe (C)
# Liczymy wystąpienia nagłówków numerowanych "1. KWALIFIKOWALNOŚĆ", "2. CELOWOŚĆ" itd.
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

# Liczba sekcji "## Pozycja:" w raporcie
POZYCJE=$(grep -cE '^## Pozycja:' "$PLAN" || true)
if [ "$POZYCJE" -eq 0 ]; then
    err "Brak sekcji '## Pozycja:' w raport.md. Każda pozycja XLSX musi mieć odpowiadającą sekcję uzasadnienia."
else
    ok "Znaleziono $POZYCJE sekcji '## Pozycja:'."

    # Sprawdź każdy z wymaganych punktów uzasadnienia.
    # Używamy IFS+for (nie pipe), żeby ERRORS aktualizowało się w bieżącym shellu (nie subshellu).
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
# Heurystyka: szukamy kwot ≥ 100000 w nagłówkach "Kwota brutto PLN:" (uwzględnia spacje
# jako separator tysięcy, np. "1 225 000", oraz markdownowe '**' wokół etykiety).
# Preprocessing: w liniach z "Kwota brutto PLN:" usuwamy spacje i gwiazdki przed regexem.
KWOTY_OVER_100K=$(grep -E 'Kwota brutto PLN:' "$PLAN" 2>/dev/null | tr -d ' *' | grep -cE 'KwotabruttoPLN:[0-9]{6,}' || true)
if [ "$KWOTY_OVER_100K" -gt 0 ]; then
    if grep -qiE '(opinię MSWiA|opinii MSWiA|wniosek-opinii-)' "$PLAN"; then
        ok "Pozycje > 100 000 zł brutto ($KWOTY_OVER_100K szt.) mają odniesienie do opinii MSWiA."
    else
        err "Pozycje > 100 000 zł brutto ($KWOTY_OVER_100K szt.), ale brak odniesienia do 'opinię MSWiA' lub 'wniosek-opinii-' w raport.md. Pkt 166 Programu wymaga opinii."
    fi
fi

# Sprawdzenie 5: pozycje w § 6050/6060 mają plan utrzymania ≥ 5 lat
if grep -qE '§[[:space:]]*60[56]0\b|\|[[:space:]]*60[56]0[[:space:]]*\|' "$PLAN"; then
    if grep -qiE '(5 lat|≥ 5 lat|>= 5 lat|pi[ęe][cć] lat|pkt 184)' "$PLAN"; then
        ok "Pozycje § 6050/6060 mają odniesienie do planu utrzymania ≥ 5 lat."
    else
        err "Pozycje § 6050/6060 obecne, ale brak frazy '5 lat' / 'pkt 184'. Wymóg pkt 184 Projektu Programu OLiOC 2027–2031."
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
# Tabela ma 12 kolumn (A..L) → po splicie na '|' awk widzi 14 pól (puste z brzegu).
# Kolumny: A=$2 podobszar, B=$3 nazwa, C=$4 dział, D=$5 rozdział, E=$6 paragraf,
#          F=$7 kwota brutto, G=$8 KG PSP, H=$9, I=$10, J=$11, K=$12, L=$13.
# Pomijamy: nagłówek (kol. F nie jest czysto liczbą) i separator (kol. B z myślnikami).
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

# rozdziel output: linie z "ROWS=" / "BAD=" + ewentualne komunikaty wierszowe
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

printf '== Podsumowanie: %d błędów ==\n' "$ERRORS"

if [ "$ERRORS" -eq 0 ]; then
    printf '✔ all checks passed\n'
    exit 0
else
    printf '✘ FAILED: %d błędów. Popraw raport.md i uruchom ponownie.\n' "$ERRORS" >&2
    exit 1
fi
