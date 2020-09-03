#!/bin/sh

PE_SERVER=$1
PE_ENV=$2

API_ENDPOINT="/classifier-api/v1/update_classes"
API_PORT=4433

URI="https://${PE_SERVER}:${API_PORT}/${API_ENDPOINT}?environment=${PE_ENV}"

TOKEN=`curl -s -S -k -X POST \
  -H 'Content-Type: application/json' \
  -H "X-Authentication: ${TOKEN}" \
  $URI
