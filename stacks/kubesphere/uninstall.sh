#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kubesphere"
NAMESPACE="kubesphere-system"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE" \
  --ignore-not-found \
  --wait --timeout 10m
kubectl delete --ignore-not-found=true namespace "$NAMESPACE" \
  --wait=true --timeout=10m
