#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="resoto"
NAMESPACE="resoto"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
