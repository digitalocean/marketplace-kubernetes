#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="openfaas"
NAMESPACE="openfaas"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"

helm uninstall ingress-nginx \
  --namespace "$NAMESPACE"

helm uninstall cert-manager \
  --namespace "$NAMESPACE"

kubectl delete namespace openfaas openfaas-fn
