#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="lakefs"
NAMESPACE="lakefs"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"