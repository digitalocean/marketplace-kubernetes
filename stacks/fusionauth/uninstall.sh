#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="fusionauth"
NAMESPACE="fusionauth"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
