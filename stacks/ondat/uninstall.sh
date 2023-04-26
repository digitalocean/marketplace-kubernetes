#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="ondat"
NAMESPACE="ondat"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
