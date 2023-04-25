#!/bin/sh

set -eu

################################################################################
# chart
################################################################################
STACK="otomi"
NAMESPACE="default"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
