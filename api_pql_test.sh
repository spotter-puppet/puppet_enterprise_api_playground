#!/bin/sh
# Reads API Access token from file, stripping any CR characters (in case the file is dos/windows format)
TOKEN=$(cat ./token | sed -e 's/\r//g') 
QUERY='inventory[certname,facts.kernel, facts.architecture] { facts.kernel="windows" }'
SERVER='demo-master.classroom.puppet.com'

curl -k -X GET \
  "https://${SERVER}:8081/pdb/query/v4"  \
  -H "X-Authentication:${TOKEN}" \
  --data-urlencode "query=${QUERY}"