#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="openebs"
NAMESPACE="openebs"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
