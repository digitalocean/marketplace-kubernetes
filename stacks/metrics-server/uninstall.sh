#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="metrics-server"
NAMESPACE="metrics-server"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
