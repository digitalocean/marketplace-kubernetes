#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="awx-operator"
NAMESPACE="awx"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
