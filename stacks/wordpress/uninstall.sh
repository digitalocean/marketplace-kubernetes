#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="wordpress"
NAMESPACE="wordpress"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
