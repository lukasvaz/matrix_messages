#!/bin/sh
# Common helpers for matrix command scripts
ENV_FILE="$(cd "$(dirname "$0")/../.." && pwd)/dev.env"

# parse KEY=VALUE or KEY:VALUE lines
get_var() {
  key="$1"
  if [ ! -f "$ENV_FILE" ]; then
    printf ''
    return
  fi
  line=$(grep -E "^[[:space:]]*${key}[[:space:]]*[:=]" "$ENV_FILE" || true)
  if [ -z "$line" ]; then
    printf ''
    return
  fi
  printf '%s' "$(printf '%s' "$line" | sed -E 's/^[^:=]*[:=][[:space:]]*//; s/[[:space:]]+$//; s/^(["'"'\\'"'])?//; s/(["'"'\\'"'])?$//')"
}

SYNAPSE_HOST=$(get_var 'SYNAPSE_HOST')
MATRIX_TOKEN=$(get_var 'SYNAPSE_TOKEN')
SYNAPSE_SERVER_NAME=$(get_var 'SYNAPSE_SERVER_NAME')

if [ -z "$SYNAPSE_HOST" ] || [ -z "$MATRIX_TOKEN" ]; then
  printf 'Required variables SYNAPSE_HOST or SYNAPSE_TOKEN not found in %s\n' "$ENV_FILE" >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  printf 'curl is required but not found. Install it and retry.\n' >&2
  exit 1
fi

api_get() {
  path="$1"
  curl -sS -X GET "http://${SYNAPSE_HOST}${path}" \
    -H "Authorization: Bearer ${MATRIX_TOKEN}" \
    -H "Content-Type: application/json"
}

api_post_json() {
  path="$1"
  json="$2"
  curl -sS -X POST "http://${SYNAPSE_HOST}${path}" \
    -H "Authorization: Bearer ${MATRIX_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$json"
}

api_delete_json() {
  path="$1"
  json="$2"
  curl -sS -X DELETE "http://${SYNAPSE_HOST}${path}" \
    -H "Authorization: Bearer ${MATRIX_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$json"
}

print_json() {
  resp="$1"
  if command -v jq >/dev/null 2>&1; then
    printf '%s\n' "$resp" | jq
  else
    printf '%s\n' "$resp"
  fi
}
