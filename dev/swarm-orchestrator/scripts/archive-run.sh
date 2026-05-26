#!/bin/sh
# archive-run.sh — tar.gz run + delete katalogu po sukcesie (gate:5).
# Wywoływany przez swarm-yolo.sh po breadcrumb gate_approved gate=5.
# Failed runs (iter-cap, scope-violation itp.) zostają nietknięte do debugu.
#
# Usage: archive-run.sh --run <RUN_ID> [--workspace <path>] [--reason <text>]
# Exit: 0 success, 1 missing run, 2 bad args, 3 archive dir missing/unwritable.

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
SWARM_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P)
. "$SWARM_ROOT/scripts/lib/paths.sh"

usage() {
  cat >&2 <<'USAGE'
Usage: archive-run.sh --run <RUN_ID> [--workspace <path>] [--reason <text>]
  --run        ID runu w .agents-swarm/runs/
  --workspace  ścieżka workspace (domyślnie $PWD)
  --reason     opcjonalny opis powodu archiwizacji (zapisany do manifestu)
USAGE
  exit 2
}

run_id=
workspace_arg=
reason="gate:5 ship"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --run) [ "$#" -ge 2 ] || usage; run_id="$2"; shift 2 ;;
    --workspace) [ "$#" -ge 2 ] || usage; workspace_arg="$2"; shift 2 ;;
    --reason) [ "$#" -ge 2 ] || usage; reason="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) usage ;;
  esac
done

[ -n "$run_id" ] || usage

if [ -n "$workspace_arg" ]; then
  WORKSPACE=$(abs_dir "$workspace_arg") || die "workspace does not exist: $workspace_arg"
else
  WORKSPACE=$(pwd -P)
fi

RUN_DIR="$WORKSPACE/.agents-swarm/runs/$run_id"
ARCHIVE_DIR="$WORKSPACE/.agents-swarm/archives"
ARCHIVE_FILE="$ARCHIVE_DIR/${run_id}.tar.gz"
MANIFEST_FILE="$ARCHIVE_DIR/${run_id}.manifest.txt"

[ -d "$RUN_DIR" ] || { echo "ERR: run dir not found: $RUN_DIR" >&2; exit 1; }

mkdir -p "$ARCHIVE_DIR" || { echo "ERR: cannot create archive dir: $ARCHIVE_DIR" >&2; exit 3; }
[ -w "$ARCHIVE_DIR" ] || { echo "ERR: archive dir not writable: $ARCHIVE_DIR" >&2; exit 3; }

# Manifest przed archiwizacją — żeby zapisać kontekst zanim katalog zniknie.
{
  printf 'RUN_ID=%s\n' "$run_id"
  printf 'archived_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'reason=%s\n' "$reason"
  printf 'workspace=%s\n' "$WORKSPACE"
  printf 'run_dir_size_bytes=%s\n' "$(du -sk "$RUN_DIR" 2>/dev/null | awk '{print $1*1024}')"
  if [ -f "$RUN_DIR/state/breadcrumbs.json" ]; then
    printf 'breadcrumbs_count=%s\n' "$(jq 'length' "$RUN_DIR/state/breadcrumbs.json" 2>/dev/null || echo 0)"
  fi
  if [ -f "$RUN_DIR/run.env" ]; then
    printf '\n--- run.env ---\n'
    cat "$RUN_DIR/run.env"
  fi
} > "$MANIFEST_FILE"

# Atomic archive: tar do .tmp, mv na finalną nazwę, dopiero rm katalogu.
TMP_ARCHIVE="${ARCHIVE_FILE}.tmp"
tar -C "$WORKSPACE/.agents-swarm/runs" -czf "$TMP_ARCHIVE" "$run_id" || {
  echo "ERR: tar failed" >&2
  rm -f "$TMP_ARCHIVE"
  exit 4
}
mv "$TMP_ARCHIVE" "$ARCHIVE_FILE"

# Sanity check: tar zawiera oczekiwany run_id jako root entry.
tar -tzf "$ARCHIVE_FILE" 2>/dev/null | head -1 | grep -q "^${run_id}/" || {
  echo "ERR: archive validation failed (run_id missing in tar root)" >&2
  exit 5
}

rm -rf "$RUN_DIR"

# Usuń też index w .runs/ żeby nie zostawiać dangling pointera.
RUN_INDEX="$SWARM_ROOT/.runs/${run_id}.env"
[ -f "$RUN_INDEX" ] && rm -f "$RUN_INDEX"

printf 'ARCHIVED=%s\n' "$ARCHIVE_FILE"
printf 'MANIFEST=%s\n' "$MANIFEST_FILE"
printf 'SIZE=%s\n' "$(du -sh "$ARCHIVE_FILE" 2>/dev/null | awk '{print $1}')"
