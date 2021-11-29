#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="victoria-metrics-cluster"
NAMESPACE="victoria-metrics-cluster"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
