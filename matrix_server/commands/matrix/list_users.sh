#!/bin/sh
# List users using Synapse admin endpoint
set -e
. "$(dirname "$0")/_lib.sh"

resp=$(curl -sS -X GET "http://${MATRIX_SERVER}/_synapse/admin/v2/users" \
  -H "Authorization: Bearer ${MATRIX_TOKEN}" \
  -H "Content-Type: application/json")

print_json "$resp"
