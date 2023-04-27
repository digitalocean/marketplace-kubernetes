#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kube-state-metrics"
NAMESPACE="kube-system"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE
