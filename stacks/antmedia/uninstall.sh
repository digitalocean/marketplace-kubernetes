#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="antmedia"
NAMESPACE="antmedia"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
