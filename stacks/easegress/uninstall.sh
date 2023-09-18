#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="easegress"
NAMESPACE="easegress"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
