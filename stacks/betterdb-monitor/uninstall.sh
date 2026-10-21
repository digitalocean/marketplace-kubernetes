#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="betterdb-monitor"
NAMESPACE="betterdb-monitor"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
