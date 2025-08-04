#!/usr/bin/env bash
set -euo pipefail

if [ -f ".env" ]; then
  set -a; source .env; set +a
else
  echo "Using .env.example defaults (copy to .env to customize)."
  set -a; source .env.example; set +a
fi

URL="http://localhost:8086/api/v2/write?org=${DOCKER_INFLUXDB_INIT_ORG}&bucket=${DOCKER_INFLUXDB_INIT_BUCKET}&precision=ns"
AUTH="Authorization: Token ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN}"
CT="Content-Type: text/plain; charset=utf-8"

curl -sS -i --request POST "$URL" --header "$AUTH" --header "$CT" --data-binary @data/nodes.lp
curl -sS -i --request POST "$URL" --header "$AUTH" --header "$CT" --data-binary @data/metrics.lp
curl -sS -i --request POST "$URL" --header "$AUTH" --header "$CT" --data-binary @data/edges.lp
