#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="valeria-one"
NAMESPACE="valeria-one"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
