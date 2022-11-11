#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="fusionauth"
NAMESPACE="fusionauth"

# delete pvcs for postgres and elastic

#helm delete --purge search
helm uninstall -n "$NAMESPACE" search
helm uninstall -n "$NAMESPACE" db
helm uninstall "$STACK" --namespace "$NAMESPACE"
kubectl delete pvc data-db-postgresql-0 -n fusionauth

helm repo remove stable
helm repo remove bitnami
helm repo remove fusionauth

