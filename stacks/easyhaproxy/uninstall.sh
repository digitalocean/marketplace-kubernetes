#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="easyhaproxy"
NAMESPACE="easyhaproxy"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
