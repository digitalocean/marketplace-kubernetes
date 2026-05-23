#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="defensia-agent-k8s"
NAMESPACE="defensia"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
