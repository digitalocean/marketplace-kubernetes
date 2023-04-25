#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="argocd"
NAMESPACE="argocd"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
