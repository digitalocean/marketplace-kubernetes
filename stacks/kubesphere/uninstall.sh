#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kubesphere"
NAMESPACE="kubesphere-system"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
