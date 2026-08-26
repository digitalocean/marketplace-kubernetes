#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="plane-app"
NAMESPACE="plane"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"

# The Traefik controller installed by deploy.sh is left in place -- other
# apps in the cluster may depend on it. Remove it yourself if nothing else
# uses it:
#   helm uninstall traefik --namespace traefik
#   kubectl delete --ignore-not-found=true namespace traefik
