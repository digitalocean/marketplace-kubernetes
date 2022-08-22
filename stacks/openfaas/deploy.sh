#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add openfaas https://openfaas.github.io/faas-netes/
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="openfaas"
CHART="openfaas/openfaas"
CHART_VERSION="10.2.2"
NAMESPACE="openfaas"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/openfaas/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/openfaas/values.yml"
fi

# Creates two namespaces, one for the OpenFaaS core services and one for the functions
kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml


helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --set functionNamespace=openfaas-fn \
  --set generateBasicAuth=true \
  --values "$values" \
  --version "$CHART_VERSION"
