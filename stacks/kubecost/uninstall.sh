#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kubecost"
NAMESPACE="kubecost"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
