#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add cyclops-ui https://cyclops-ui.com/helm
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="cyclops"
CHART="cyclops-ui/cyclops"
CHART_VERSION="0.14.4"
NAMESPACE="cyclops"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/cyclops/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/cyclops/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
