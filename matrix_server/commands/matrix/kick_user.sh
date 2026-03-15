#!/bin/sh
# Kick a local user from a room using the homeserver API
set -e
. "$(dirname "$0")/_lib.sh"

usage() {
  printf '%s\n' "Usage: $(basename "$0") [ROOM_ID] [USER_ID] [REASON]" > /dev/tty
  printf '%s\n' "If arguments omitted the script will prompt for them." > /dev/tty
}

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  usage
  exit 0
fi

prompt() { printf '%s' "$1" > /dev/tty; read ans < /dev/tty; printf '%s' "$ans"; }

if [ -n "$1" ]; then
  ROOM_ID="$1"
else
  ROOM_ID=$(prompt "Room id (eg: !abc:domain or #alias:domain): ")
fi

if [ -n "$2" ]; then
  USER_ID="$2"
else
  USER_ID=$(prompt "User id to kick (eg: @user:domain): ")
fi

if [ -n "$3" ]; then
  REASON="$3"
else
  REASON=$(prompt "Reason (optional, enter to skip): ")
fi

if [ -z "$ROOM_ID" ] || [ -z "$USER_ID" ]; then
  printf 'Room id and user id required, aborting.\n' > /dev/tty
  exit 1
fi

# URL-encode helper (uses python3 if available for robust encoding)
url_encode() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$1"
  else
    # minimal fallback: escape # and ? and /
    printf '%s' "$1" | sed 's/#/%23/g; s/?/%3F/g; s/\//%2F/g; s/:/%3A/g; s/@/%40/g; s/\$/%24/g'
  fi
}

ENC_ROOM=$(url_encode "$ROOM_ID")

# build payload
if [ -n "$REASON" ]; then
  payload=$(cat <<JSON
{
  "user_id": "$USER_ID",
  "reason": "$REASON"
}
JSON
)
else
  payload=$(cat <<JSON
{
  "user_id": "$USER_ID"
}
JSON
)
fi

# Try the client API kick endpoint. api_post_json is expected to add auth and host from _lib.sh
resp=$(api_post_json "/_matrix/client/v3/rooms/${ENC_ROOM}/kick" "$payload")
print_json "$resp"
