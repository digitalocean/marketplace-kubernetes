#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kube-prometheus-stack"
NAMESPACE="kube-prometheus-stack"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
