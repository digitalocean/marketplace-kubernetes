#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="keda"
NAMESPACE="keda"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
