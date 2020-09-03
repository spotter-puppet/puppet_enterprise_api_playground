#!/bin/sh

PE_SERVER=$1
PE_USER=$2
PE_PASS=$3

API_ENDPOINT="/rbac-api/v1/auth/token"
API_PORT=4433
LIFETIME="1h"
LABEL="Token"

PAYLOAD="{\"login\": $PE_USER, \"password\": $PE_PASS, \"lifetime\": $LIFETIME, \"label\": $LABEL}"
URI="https://${PE_SERVER}:${API_PORT}/${API_ENDPOINT}"

TOKEN=`curl -s -S -k -X POST \
  -H 'Content-Type: application/json' \
  -d $PAYLOAD \
  $URI \
  | jq -r '.token'`
  
echo "The generated token for $PE_SERVER is $TOKEN"
echo ${TOKEN} >> ./pe_token
