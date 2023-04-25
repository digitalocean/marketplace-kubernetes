#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="pixie"
NAMESPACE="pixie"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
