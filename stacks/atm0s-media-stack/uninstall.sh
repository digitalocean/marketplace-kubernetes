#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="atm0s-media-stack"
NAMESPACE="atm0s-media"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
