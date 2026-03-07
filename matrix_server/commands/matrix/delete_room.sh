#!/bin/sh
# Delete a room by ID
set -e
. "$(dirname "$0")/_lib.sh"

prompt() { printf '%s' "$1" > /dev/tty; read ans < /dev/tty; printf '%s' "$ans"; }
room_id=$(prompt "Room id to delete (eg: !abc:domain or #alias:domain): ")
if [ -z "$room_id" ]; then printf 'No room id provided, aborting.\n' > /dev/tty; exit 1; fi
payload='{"purge":true}'
resp=$(api_delete_json "/_synapse/admin/v2/rooms/${room_id}" "$payload")
print_json "$resp"
