#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="denpex-gpu-watcher"
NAMESPACE="denpex-gpu-watcher"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
