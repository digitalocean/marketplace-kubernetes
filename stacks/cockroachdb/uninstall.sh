#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="cockroachdb"
NAMESPACE="cockroachdb"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
