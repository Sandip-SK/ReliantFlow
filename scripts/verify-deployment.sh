#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="reliantflow"
DEPLOYMENT="reliantflow"

echo "Checking Kubernetes rollout..."

kubectl rollout status \
  deployment/"$DEPLOYMENT" \
  -n "$NAMESPACE" \
  --timeout=180s

echo "Checking pod readiness..."

READY=$(kubectl get deployment "$DEPLOYMENT" \
  -n "$NAMESPACE" \
  -o jsonpath='{.status.readyReplicas}')

DESIRED=$(kubectl get deployment "$DEPLOYMENT" \
  -n "$NAMESPACE" \
  -o jsonpath='{.spec.replicas}')

echo "Ready replicas: $READY/$DESIRED"

if [[ "$READY" != "$DESIRED" ]]; then
    echo "Deployment verification failed."
    exit 1
fi

kubectl apply -f k8s/

if ! kubectl rollout status deployment/reliantflow \
    -n reliantflow \
    --timeout=180s; then

    echo "Deployment failed. Rolling back..."

    kubectl rollout undo deployment/reliantflow \
        -n reliantflow

    exit 1
fi

echo "Deployment verification passed."