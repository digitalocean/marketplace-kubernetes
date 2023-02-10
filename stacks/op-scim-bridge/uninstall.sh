#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="op-scim-bridge"
NAMESPACE="op-scim-bridge"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
