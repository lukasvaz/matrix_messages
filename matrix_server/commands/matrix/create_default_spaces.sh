#!/bin/sh
# Create two default spaces: Canales and Tareas
set -e
. "$(dirname "$0")/_lib.sh"

sanitize_alias() {
  # lower-case, replace spaces and invalid chars with underscore
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9._-]+/_/g'
}

create_space() {
  name="$1"
  alias_local=$(sanitize_alias "$name")
  payload=$(cat <<JSON
{
  "creation_content": { "type": "m.space", "m.federate": false },
  "name": "${name}",
  "preset": "public_chat",
  "visibility": "public",
  "room_alias_name": "${alias_local}",
  "topic": "${name}"
}
JSON
)
  printf 'Creating space "%s" (alias local: %s)\n' "$name" "$alias_local" > /dev/tty
  resp=$(api_post_json '/_matrix/client/v3/createRoom' "$payload")
  print_json "$resp"
}

# Create the two spaces
create_space "Canales"
create_space "Tareas"
