#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="ingress-nginx"
NAMESPACE="ingress-nginx"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
