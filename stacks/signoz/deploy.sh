#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add signoz https://charts.signoz.io
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="signoz"
CHART="signoz/signoz"
CHART_VERSION="0.86.0"
NAMESPACE="signoz"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/signoz/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/SigNoz/charts/refs/heads/main/charts/signoz/values.yaml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
