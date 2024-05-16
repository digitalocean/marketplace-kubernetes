#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kubescape-operator"
NAMESPACE="kubescape"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
