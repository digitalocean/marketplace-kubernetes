#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="ngrok-ingress-controller"
NAMESPACE="ngrok-ingress-controller"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
