#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add openfaas https://openfaas.github.io/faas-netes/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="openfaas"
CHART="openfaas/openfaas"
NAMESPACE="openfaas"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/openfaas/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/openfaas/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \

helm upgrade ingress-nginx \
  --namespace "$NAMESPACE"

helm upgrade cert-manager \
  --namespace "$NAMESPACE"
