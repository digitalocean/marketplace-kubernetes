#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add gopaddle https://gopaddle-io.github.io/gopaddle-lite/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="gopaddle"
CHART="gopaddle/gopaddle"
CHART_VERSION="5.0"
NAMESPACE="gopaddle"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/gopaddle-lite/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/gopaddle-lite/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 15m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
