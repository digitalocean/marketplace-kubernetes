#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add ondat https://ondat.github.io/charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="ondat"
CHART="ondat/ondat"
CHART_VERSION="0.0.1"
NAMESPACE="ondat"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/ondat/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/ondat/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
