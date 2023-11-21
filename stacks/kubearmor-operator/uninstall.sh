#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kubearmor-operator"
NAMESPACE="kubearmor"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
