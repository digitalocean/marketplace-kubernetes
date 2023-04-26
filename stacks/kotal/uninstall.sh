#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kotal"
NAMESPACE="kotal"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
