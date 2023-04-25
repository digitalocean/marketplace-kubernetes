#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="apache-pulsar"
NAMESPACE="pulsar"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
