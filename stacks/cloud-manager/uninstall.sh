#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="cloud-manager"
NAMESPACE="einnovator"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
