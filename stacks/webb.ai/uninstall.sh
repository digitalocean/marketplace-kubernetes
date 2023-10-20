#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="webbai-agent"
NAMESPACE="webbai"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
