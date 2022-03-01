#!/bin/sh

################################################################################
# chart
################################################################################
STACK="epinio"
NAMESPACE="epinio"

# Remove epinio
helm uninstall "$STACK" \
  --namespace "$NAMESPACE" \
  --wait || true # Ignore missing
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"

# Remove traefik
helm uninstall -n traefik traefik --wait || true
kubectl delete --ignore-not-found=true namespace traefik

# Remove cert-manager
helm uninstall -n cert-manager cert-manager --wait || true
kubectl delete --ignore-not-found=true namespace cert-manager
