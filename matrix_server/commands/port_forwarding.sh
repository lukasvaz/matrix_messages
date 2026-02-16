#!/usr/bin/env bash
set -euo pipefail

# Parent .env location
ENV_FILE="$(cd "$(dirname "$0")/.." && pwd)/dev.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE not found" >&2
  exit 1
fi

# Simple parser: accepts KEY=VALUE or KEY:VALUE, ignores comments and blanks
get_var() {
  local key="$1"
  local line
  line=$(grep -E "^[[:space:]]*${key}[[:space:]]*[:=]" "$ENV_FILE" || true)
  if [ -z "$line" ]; then
    printf ''
    return
  fi
  printf '%s' "$(printf '%s' "$line" | sed -E 's/^[^:=]*[:=][[:space:]]*//; s/[[:space:]]+$//')"
}

usage() {
  cat <<EOF
Usage: $(basename "$0") <command>
Commands:
  up      Create adb reverse using SYNAPSE_HOST_PORT and SYNAPSE_CONTAINER_PORT from .env
  down    Remove all adb reverse forwards (adb reverse --remove-all)
EOF
}

check_adb() {
  if ! command -v adb >/dev/null 2>&1; then
    echo "Error: adb not found in PATH" >&2
    exit 1
  fi
}

cmd=${1:-}
case "$cmd" in
  up)
    check_adb
    SYNAPSE_HOST_PORT=$(get_var 'SYNAPSE_HOST_PORT')
    SYNAPSE_CONTAINER_PORT=$(get_var 'SYNAPSE_CONTAINER_PORT')
    if [ -z "$SYNAPSE_HOST_PORT" ] || [ -z "$SYNAPSE_CONTAINER_PORT" ]; then
      echo "Error: SYNAPSE_HOST_PORT and SYNAPSE_CONTAINER_PORT must be set in $ENV_FILE" >&2
      exit 1
    fi
    echo "Setting up adb reverse: host:$SYNAPSE_HOST_PORT -> container:$SYNAPSE_CONTAINER_PORT"
    adb reverse "tcp:$SYNAPSE_HOST_PORT" "tcp:$SYNAPSE_CONTAINER_PORT"
    echo "Port forwarding set up: localhost:$SYNAPSE_HOST_PORT -> container:$SYNAPSE_CONTAINER_PORT"
    ;;
  down)
    check_adb
    echo "Removing all adb reverse forwards"
    adb reverse --remove-all
    echo "All adb reverse forwards removed"
    ;;
  -*|'' )
    usage
    exit 2
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    usage
    exit 2
    ;;
esac

