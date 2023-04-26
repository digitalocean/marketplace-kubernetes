#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="antmedia"
NAMESPACE="antmedia"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
