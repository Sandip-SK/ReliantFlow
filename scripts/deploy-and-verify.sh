#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="reliantflow"
DEPLOYMENT="reliantflow"
CONTAINER="reliantflow"

IMAGE="${1:?Usage: $0 <image>}"

echo "Deploying image:"
echo "$IMAGE"

kubectl set image deployment/"$DEPLOYMENT" \
    "$CONTAINER"="$IMAGE" \
    -n "$NAMESPACE"

echo "Waiting for deployment rollout..."

if ! kubectl rollout status \
    deployment/"$DEPLOYMENT" \
    -n "$NAMESPACE" \
    --timeout=180s; then

    echo "Kubernetes rollout failed. Rolling back..."

    kubectl rollout undo deployment/"$DEPLOYMENT" \
        -n "$NAMESPACE"

    exit 1
fi

echo "Kubernetes rollout succeeded."

echo "Waiting for metrics to accumulate..."
sleep 60

echo "Running SLO health gate..."

if ! ./scripts/check-slo.sh; then

    echo "SLO health gate FAILED."
    echo "Rolling back deployment..."

    kubectl rollout undo deployment/"$DEPLOYMENT" \
        -n "$NAMESPACE"

    kubectl rollout status deployment/"$DEPLOYMENT" \
        -n "$NAMESPACE" \
        --timeout=180s

    echo "Rollback completed."

    exit 1
fi

echo "Deployment passed all health checks."