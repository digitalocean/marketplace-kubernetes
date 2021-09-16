#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="chatwoot"
NAMESPACE="chatwoot"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
