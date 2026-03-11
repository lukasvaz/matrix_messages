#!/bin/sh
# Add a child room to a space (m.space.child and m.space.parent)
set -e
. "$(dirname "$0")/_lib.sh"

usage() {
  printf '%s\n' "Usage: $(basename "$0") [PARENT_ROOM_ID_OR_ALIAS] [CHILD_ROOM_ID_OR_ALIAS]" > /dev/tty
  printf '%s\n' "If arguments omitted the script will prompt for them." > /dev/tty
}

prompt() { printf '%s' "$1" > /dev/tty; read ans < /dev/tty; printf '%s' "$ans"; }

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  usage
  exit 0
fi

PARENT="$1"
CHILD="$2"

if [ -z "$PARENT" ]; then
  PARENT=$(prompt "Parent space id or alias (eg: !spaceid:host or #alias:host): ")
fi
if [ -z "$CHILD" ]; then
  CHILD=$(prompt "Child room id or alias (eg: !roomid:host or #alias:host): ")
fi

if [ -z "$PARENT" ] || [ -z "$CHILD" ]; then
  printf 'Both parent and child room identifiers are required.\n' > /dev/tty
  exit 1
fi

# derive short server host (strip optional :port)
SERVER_HOST=$(printf '%s' "$SYNAPSE_HOST" | sed -E 's/:[0-9]+$//')

# URL-encode helper
url_encode() {
  s="$1"
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1], safe=""))' "$s" | tr -d '\n'
  else
    printf '%s' "$s" | sed -e 's/%/%25/g' -e 's/#/%23/g' -e 's/:/%3A/g' -e 's/\//%2F/g' -e 's/@/%40/g' -e 's/ /%20/g' -e 's/!/%21/g'
  fi
}

enc_parent=$(url_encode "$PARENT")
enc_child=$(url_encode "$CHILD")

printf 'Adding child relationship:\n parent=%s\n child=%s\n' "$PARENT" "$CHILD" > /dev/tty

# PUT m.space.child on parent
parent_put_url="http://${SYNAPSE_HOST}/_matrix/client/v3/rooms/${enc_parent}/state/m.space.child/${enc_child}"
parent_body='{"via":["'"${SERVER_HOST}"'"],"suggested":false}'
parent_put_resp=$(curl -sS -X PUT "$parent_put_url" \
  -H "Authorization: Bearer ${MATRIX_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$parent_body")

printf 'm.space.child PUT response:\n' > /dev/tty
if command -v jq >/dev/null 2>&1; then
  printf '%s\n' "$parent_put_resp" | jq
else
  printf '%s\n' "$parent_put_resp"
fi

# PUT m.space.parent on child
child_put_url="http://${SYNAPSE_HOST}/_matrix/client/v3/rooms/${enc_child}/state/m.space.parent/${enc_parent}"
child_body='{"via":["'"${SERVER_HOST}"'"],"canonical":true}'
child_put_resp=$(curl -sS -X PUT "$child_put_url" \
  -H "Authorization: Bearer ${MATRIX_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$child_body")

printf 'm.space.parent PUT response:\n' > /dev/tty
if command -v jq >/dev/null 2>&1; then
  printf '%s\n' "$child_put_resp" | jq
else
  printf '%s\n' "$child_put_resp"
fi

