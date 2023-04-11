#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="loki"
NAMESPACE="loki-stack"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
