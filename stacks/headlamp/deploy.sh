#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add headlamp https://headlamp-k8s.github.io/headlamp/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="headlamp"
CHART="headlamp/headlamp"
CHART_VERSION="0.20.0"
NAMESPACE="headlamp"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/$STACK/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/${STACK}/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
