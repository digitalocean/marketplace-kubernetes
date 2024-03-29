#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="sosivio"
NAMESPACE="sosivio"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
