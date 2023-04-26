#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="paralus"
NAMESPACE="paralus"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
