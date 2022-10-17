#!/bin/sh

set -x
set -e

################################################################################
# repo
################################################################################
helm repo add paralus https://paralus.github.io/helm-charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="paralus"
CHART="paralus/ztka"
CHART_VERSION="0.1.7"
NAMESPACE="paralus"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/paralus/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/paralus/helm-charts/main/examples/values.dev-generic.yaml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
