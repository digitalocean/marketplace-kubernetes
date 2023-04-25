#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="cloudcasa"
NAMESPACE="cloudcasa-io"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
