#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="headlamp"
NAMESPACE="headlamp"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
