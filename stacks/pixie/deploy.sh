#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add pixie-operator https://pixie-operator-charts.storage.googleapis.com
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="pixie"
CHART="pixie-operator/pixie-operator-chart"
CHART_VERSION="0.0.25"
NAMESPACE="pixie"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/pixie/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/pixie/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
