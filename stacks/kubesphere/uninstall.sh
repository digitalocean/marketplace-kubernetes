#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kubesphere"
NAMESPACE="kubesphere-system"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
