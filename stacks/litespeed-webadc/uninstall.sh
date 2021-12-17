#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="ls-k8s-webadc"
NAMESPACE="ls-k8s-webadc"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
