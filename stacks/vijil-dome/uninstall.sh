#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="vijil-dome"
NAMESPACE="vijil-dome"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
