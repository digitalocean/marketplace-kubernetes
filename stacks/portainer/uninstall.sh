#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="portainer"
NAMESPACE="portainer"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"

kubectl delete --ignore-not-found=true namespace portainer
