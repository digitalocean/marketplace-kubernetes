#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="cert-manager"
NAMESPACE="cert-manager"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
