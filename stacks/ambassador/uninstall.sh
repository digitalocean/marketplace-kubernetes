#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="edge-stack"
NAMESPACE="ambassador"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
