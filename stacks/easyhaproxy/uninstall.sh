#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="easyhaproxy"
NAMESPACE="easyhaproxy"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"

# The certbot volume is kept by helm uninstall; deleting the namespace removes it
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"

# Earlier versions of this stack ran a DaemonSet pinned to this node label
kubectl label nodes --all "easyhaproxy/node-"
