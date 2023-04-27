#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="jaeger"
NAMESPACE="jaeger"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
