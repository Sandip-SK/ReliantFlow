#!/usr/bin/env bash

set -euo pipefail

PROMETHEUS_URL="http://localhost:9090"
SLO_THRESHOLD="0.999"

QUERY='reliantflow:availability:ratio5m'

echo "Checking ReliantFlow availability SLO..."

RESPONSE=$(curl -sG "$PROMETHEUS_URL/api/v1/query" \
  --data-urlencode "query=$QUERY")

VALUE=$(echo "$RESPONSE" | python -c '
import json
import sys

data = json.load(sys.stdin)
result = data["data"]["result"]

if not result:
    print("NO_DATA")
    sys.exit(0)

print(result[0]["value"][1])
')

if [[ "$VALUE" == "NO_DATA" ]]; then
    echo "No SLO data available."
    exit 1
fi

echo "Current availability: $VALUE"
echo "Required availability: $SLO_THRESHOLD"

python - "$VALUE" "$SLO_THRESHOLD" <<'PY'
import sys

availability = float(sys.argv[1])
threshold = float(sys.argv[2])

if availability < threshold:
    print("SLO CHECK FAILED")
    sys.exit(1)

print("SLO CHECK PASSED")
PY

LATENCY_THRESHOLD="0.5"

LATENCY_QUERY='histogram_quantile(0.95, sum by (le) (rate(flask_http_request_duration_seconds_bucket[5m])))'

LATENCY_RESPONSE=$(curl -sG "$PROMETHEUS_URL/api/v1/query" \
  --data-urlencode "query=$LATENCY_QUERY")

LATENCY=$(echo "$LATENCY_RESPONSE" | python -c '
import json
import sys

data = json.load(sys.stdin)
result = data["data"]["result"]

if not result:
    print("NO_DATA")
    sys.exit(0)

print(result[0]["value"][1])
')

if [[ "$LATENCY" == "NO_DATA" ]]; then
    echo "No latency data available."
    exit 1
fi

echo "Current P95 latency: ${LATENCY}s"
echo "Required P95 latency: < ${LATENCY_THRESHOLD}s"

python - "$LATENCY" "$LATENCY_THRESHOLD" <<'PY'
import sys

latency = float(sys.argv[1])
threshold = float(sys.argv[2])

if latency >= threshold:
    print("LATENCY CHECK FAILED")
    sys.exit(1)

print("LATENCY CHECK PASSED")
PY