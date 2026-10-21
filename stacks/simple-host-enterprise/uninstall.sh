#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="simple-host-enterprise"
NAMESPACE="simple-host"

echo "Deleting the simple-host namespace: the database, and the envelope key that reads every site in the bucket. The bucket itself is left as it is."

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
helm uninstall traefik --namespace simple-host-ingress
kubectl delete --ignore-not-found=true namespace simple-host-ingress
