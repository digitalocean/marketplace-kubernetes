#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="openfaas"
NAMESPACE="openfaas"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"

kubectl delete namespace openfaas openfaas-fn
