#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add jetstack https://charts.jetstack.io
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="cert-manager"
CHART="jetstack/cert-manager"
CHART_VERSION="v1.19.1"
NAMESPACE="cert-manager"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/cert-manager/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/cert-manager/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
