#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="fusionauth"
NAMESPACE="fusionauth"

helm uninstall -n "$NAMESPACE" search
helm uninstall -n "$NAMESPACE" db
helm uninstall "$STACK" --namespace "$NAMESPACE"

helm repo remove fusionauth

kubectl delete ns fusionauth

