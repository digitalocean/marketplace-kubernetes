#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="vmoperator"
NAMESPACE="victoria-metrics"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"