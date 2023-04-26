#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="infisical"
NAMESPACE="infisical"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
