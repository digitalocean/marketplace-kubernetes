#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="cloudcasa"
NAMESPACE="default"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
