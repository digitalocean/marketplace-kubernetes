#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="wordpress-kubernetes"
NAMESPACE="wordpress"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"

kubectl delete ns "$NAMESPACE"
