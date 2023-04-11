#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="memphis"
NAMESPACE="memphis"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
