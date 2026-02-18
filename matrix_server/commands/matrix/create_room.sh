#!/bin/sh
# Create a room interactively
set -e
. "$(dirname "$0")/_lib.sh"

dbg() { printf '%s\n' "$1" >&2; }

prompt() { printf '%s' "$1" > /dev/tty; read ans < /dev/tty; printf '%s' "$ans"; }
required_input() { while :; do printf '%s' "$1" > /dev/tty; read val < /dev/tty; [ -n "$val" ] && { printf '%s' "$val"; return; }; printf 'This value is required.\n' > /dev/tty; done }
required_choice() { while :; do printf '%s' "$1" > /dev/tty; read val < /dev/tty; for c in "$@"; do [ "$val" = "$c" ] && { printf '%s' "$val"; return; }; done; printf 'Invalid choice. Valid: %s\n' "$*" > /dev/tty; done }

name=$(required_input "Room name: ")
private=$(required_choice "Is the room private? (yes or no): " yes no)
if [ "$private" = "yes" ]; then preset=private_chat; else preset=public_chat; fi
alias=$(required_input "Room alias local part (without # or :domain): ")
federate=$(required_choice "Federate? (yes or no): " yes no)
if [ "$federate" = "yes" ]; then federate_bool=true; else federate_bool=false; fi
topic=$(required_input "Topic: ")

payload=$(cat <<JSON
{
  "creation_content": { "m.federate": ${federate_bool} },
  "name": "${name}",
  "preset": "${preset}",
  "room_alias_name": "${alias}",
  "topic": "${topic}"
}
JSON
)

printf 'Request payload:\n%s\n' "$payload" > /dev/tty
resp=$(api_post_json '/_matrix/client/v3/createRoom' "$payload")
print_json "$resp"
