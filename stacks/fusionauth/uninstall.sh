#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="fusionauth"
NAMESPACE="fusionauth"

helm repo remove stable
helm repo remove bitnami
helm repo remove fusionauth

helm uninstall -n "$NAMESPACE" search
helm uninstall -n "$NAMESPACE" db
helm uninstall "$STACK" --namespace "$NAMESPACE"

