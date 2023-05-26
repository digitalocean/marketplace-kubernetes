#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="devtron"
NAMESPACE="devtroncd"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
