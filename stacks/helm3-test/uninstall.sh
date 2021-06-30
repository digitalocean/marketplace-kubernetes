#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="helm3-test"
NAMESPACE="helm3-test"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
