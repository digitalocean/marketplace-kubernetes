#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="fusionauth"
NAMESPACE="fusionauth"

helm uninstall -n "$NAMESPACE" search-elasticsearch
helm uninstall -n "$NAMESPACE" postgres-operator
helm uninstall "$STACK" --namespace "$NAMESPACE"

helm repo remove fusionauth

kubectl delete ns fusionauth
