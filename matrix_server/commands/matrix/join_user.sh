#!/bin/sh
# Join a local user to a room using Synapse admin API
set -e
. "$(dirname "$0")/_lib.sh"

usage() {
  printf '%s\n' "Usage: $(basename "$0") [ROOM_ID_OR_ALIAS] [USER_ID]" > /dev/tty
  printf '%s\n' "If arguments omitted the script will prompt for them." > /dev/tty
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  usage
  exit 0
fi

prompt() { printf '%s' "$1" > /dev/tty; read ans < /dev/tty; printf '%s' "$ans"; }

if [ -n "$1" ]; then
  ROOM_ID_OR_ALIAS="$1"
else
  ROOM_ID_OR_ALIAS=$(prompt "Room id or alias (eg: !abc:domain or #alias:domain): ")
fi

if [ -n "$2" ]; then
  USER_ID="$2"
else
  USER_ID=$(prompt "User id to join (eg: @user:domain): ")
fi

if [ -z "$ROOM_ID_OR_ALIAS" ] || [ -z "$USER_ID" ]; then
  printf 'Room id and user id required, aborting.\n' > /dev/tty
  exit 1
fi

# URL-encode simple characters (# must be encoded)
url_encode() {
  # Use python3 if available for robust encoding, otherwise do a minimal escape for '#'
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$1"
  else
    printf '%s' "$1" | sed 's/#/%23/g'
  fi
}

ENC_PATH=$(url_encode "$ROOM_ID_OR_ALIAS")

payload=$(cat <<JSON
{
  "user_id": "$USER_ID"
}
JSON
)

resp=$(api_post_json "/_synapse/admin/v1/join/${ENC_PATH}" "$payload")
print_json "$resp"
