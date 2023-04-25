#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="helpy"
NAMESPACE="helpy"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
