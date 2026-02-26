#!/bin/sh
# Add a child room to a space (m.space.child)
set -e
. "$(dirname "$0")/_lib.sh"

# helper to read from controlling tty
prompt() { printf '%s' "$1" > /dev/tty; read ans < /dev/tty; printf '%s' "$ans"; }

# derive short server host (strip optional :port)
SERVER_HOST=$(printf '%s' "$SYNAPSE_HOST" | sed -E 's/:[0-9]+$//')

# available spaces (alias local parts)
SPACES="canales tareas"

# Prompt for parent: accept full canonical alias (#canales:host), local name (canales) or name:host
parent_room_id=$(prompt "Enter space ID: ")


printf 'New room data: %s\n' > /dev/tty
name=$(prompt "Child room name: ")
alias=$(prompt "Child room alias local part (without # or :domain): ")
private=$(prompt "Is the child room private? (yes or no): ")
if [ "$private" = "yes" ]; then preset=private_chat; else preset=public_chat; fi
federate=$(prompt "Federate? (yes or no): ")
if [ "$federate" = "yes" ]; then federate_bool=true; else federate_bool=false; fi
topic=$(prompt "Child room topic: ")        


# --data-raw $'{"preset":"private_chat",
# "visibility":"private",
# "power_level_content_override":{"events":{"m.room.name":50,"m.room.avatar":50,
# "m.room.power_levels":100,"m.room.history_visibility":100,
# "m.room.canonical_alias":50,"m.room.tombstone":100,"m.room.server_acl":100,"m.room.encryption":100,
# "org.matrix.msc3401.call.member":0}},
# "initial_state":[{"type":"m.room.guest_access","state_key":"","content":{"guest_access":"can_join"}},
# {"type":"m.room.encryption","state_key":"","content":{"algorithm":"m.megolm.v1.aes-sha2"}},
# {"type":"m.space.parent","content":{"via":["matrix.org"],"canonical":true},
# "state_key":"\u0021bxxcjXqDhNYBTpjfJC:matrix.org"},
# {"type":"m.room.join_rules",
# "content":{"join_rule":"restricted","allow":[{"type":"m.room_membership","room_id":"\u0021bxxcjXqDhNYBTpjfJC:matrix.org"}]}}],"name":"hijo"}'

# # creating the new room
payload=$(cat <<JSON
{
  "creation_content": { "m.federate": ${federate_bool} },
  "name": "${name}",
  "preset": "${preset}",
  "room_alias_name": "${alias}",
  "topic": "${topic}",
  "initial_state": [
    {
      "type": "m.room.encryption",
      "state_key": "",
      "content": { "algorithm": "m.megolm.v1.aes-sha2" }
    },
    {
      "type": "m.space.parent",
      "content": { "via": ["${SYNAPSE_SERVER_NAME}"], "canonical": true },
      "state_key": "${parent_room_id}"
    }
  ]

}
JSON
)

printf 'Request payload:\n%s\n' "$payload" > /dev/tty
resp=$(api_post_json '/_matrix/client/v3/createRoom' "$payload")
print_json "$resp"

# extract created child room_id from response
child_room_id=$(printf '%s' "$resp" | jq -r '.room_id // empty' 2>/dev/null || true)
if [ -z "$child_room_id" ]; then
  child_room_id=$(printf '%s' "$resp" | sed -n 's/.*"room_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
fi

if [ -n "$child_room_id" ]; then
  printf 'Setting m.space.child on parent %s -> %s\n' "$parent_room_id" "$child_room_id" > /dev/tty

  # URL-encode helper
  url_encode() {
    s="$1"
    if command -v python3 >/dev/null 2>&1; then
      python3 - <<PY - "$s" | tr -d '\n'
import sys, urllib.parse
print(urllib.parse.quote(sys.argv[1], safe=''))
PY
    else
      printf '%s' "$s" | sed -e 's/%/%25/g' -e 's/#/%23/g' -e 's/:/%3A/g' -e 's/\//%2F/g' -e 's/@/%40/g' -e 's/ /%20/g'
    fi
  }

  enc_key=$(url_encode "$child_room_id")

  child_put_resp=$(curl -sS -X PUT "http://${SYNAPSE_HOST}/_matrix/client/v3/rooms/${parent_room_id}/state/m.space.child/${enc_key}" \
    -H "Authorization: Bearer ${MATRIX_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{"via":["'"${SERVER_HOST}"'"],"suggested":false}')

  printf 'add child response:\n' > /dev/tty
  if command -v jq >/dev/null 2>&1; then
    printf '%s\n' "$child_put_resp" | jq
  else
    printf '%s\n' "$child_put_resp"
  fi
fi

