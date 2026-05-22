#!/bin/sh
# eli-fetch.sh — cienki, deterministyczny wrapper na api.sejm.gov.pl/eli.
# POSIX sh. Pretty-print JSON przez python3, gdy dostępny.
#
# Użycie:
#   eli-fetch.sh publishers
#   eli-fetch.sh search "Prawo zamówień publicznych" [limit] [offset]
#   eli-fetch.sh year DU 2024
#   eli-fetch.sh meta DU 2024 1222
#   eli-fetch.sh struct DU 2024 1222
#   eli-fetch.sh references DU 2024 1222
#   eli-fetch.sh text DU 2024 1222 [html|pdf]     # html -> stdout, pdf -> plik
set -eu

BASE="https://api.sejm.gov.pl/eli"
TIMEOUT=25

die() { echo "ERROR: $*" >&2; exit 1; }

# get URL -> stdout (JSON pretty gdy python3 jest)
get_json() {
  url="$1"
  if command -v python3 >/dev/null 2>&1; then
    curl -sS --max-time "$TIMEOUT" "$url" | python3 -m json.tool
  else
    curl -sS --max-time "$TIMEOUT" "$url"
  fi
}

# url-encode argumentu (RFC 3986, znaki bezpieczne: A-Za-z0-9_.~-)
urlencode() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import sys,urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$1"
  else
    # fallback: spacje na %20 (wystarczające dla prostych fraz)
    printf '%s' "$1" | sed 's/ /%20/g'
  fi
}

cmd="${1:-}"
[ -n "$cmd" ] || die "brak komendy. Zob. nagłówek skryptu."
shift || true

case "$cmd" in
  publishers)
    get_json "$BASE/acts"
    ;;
  search)
    [ "$#" -ge 1 ] || die "search wymaga frazy: eli-fetch.sh search \"<tytuł>\" [limit] [offset]"
    q=$(urlencode "$1"); limit="${2:-10}"; offset="${3:-0}"
    get_json "$BASE/acts/search?title=$q&limit=$limit&offset=$offset"
    ;;
  year)
    [ "$#" -ge 2 ] || die "year wymaga: <PUB> <ROK>"
    get_json "$BASE/acts/$1/$2"
    ;;
  meta)
    [ "$#" -ge 3 ] || die "meta wymaga: <PUB> <ROK> <POZ>"
    get_json "$BASE/acts/$1/$2/$3"
    ;;
  struct)
    [ "$#" -ge 3 ] || die "struct wymaga: <PUB> <ROK> <POZ>"
    get_json "$BASE/acts/$1/$2/$3/struct"
    ;;
  references)
    [ "$#" -ge 3 ] || die "references wymaga: <PUB> <ROK> <POZ>"
    get_json "$BASE/acts/$1/$2/$3/references"
    ;;
  text)
    [ "$#" -ge 3 ] || die "text wymaga: <PUB> <ROK> <POZ> [html|pdf]"
    fmt="${4:-html}"
    case "$fmt" in
      html) curl -sS --max-time "$TIMEOUT" "$BASE/acts/$1/$2/$3/text.html" ;;
      pdf)
        out="$1-$2-$3.pdf"
        curl -sS --max-time "$TIMEOUT" -o "$out" "$BASE/acts/$1/$2/$3/text.pdf"
        echo "Zapisano: $out" >&2
        ;;
      *) die "nieznany format '$fmt' (html|pdf)" ;;
    esac
    ;;
  *)
    die "nieznana komenda '$cmd'. Zob. nagłówek skryptu."
    ;;
esac
