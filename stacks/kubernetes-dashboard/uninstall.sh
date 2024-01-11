#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kubernetes-dashboard"
NAMESPACE="kubernetes-dashboard"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
