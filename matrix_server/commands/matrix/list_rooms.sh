#!/bin/sh
# List rooms using Synapse admin endpoint
set -e
. "$(dirname "$0")/_lib.sh"
resp=$(api_get '/_synapse/admin/v1/rooms')
print_json "$resp"
