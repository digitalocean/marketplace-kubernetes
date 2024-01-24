#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kubefirst"
NAMESPACE="kubefirst"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
