#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kapp-controller"
NAMESPACE="kapp-controller"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
