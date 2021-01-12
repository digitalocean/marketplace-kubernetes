#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add ei https://cdn.einnovator.org/charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="cloud-manager"
CHART="ei/einnovator-devops"
CHART_VERSION="1.0.0"
NAMESPACE="einnovator"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/cloud-manager/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/cloud-manager/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
