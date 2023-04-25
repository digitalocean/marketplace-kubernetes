#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="posthog"
NAMESPACE="posthog"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
