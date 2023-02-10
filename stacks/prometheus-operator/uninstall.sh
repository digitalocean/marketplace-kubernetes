#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="prometheus-operator"
NAMESPACE="prometheus-operator"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
