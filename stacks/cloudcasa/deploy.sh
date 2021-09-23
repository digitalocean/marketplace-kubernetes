#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add cloudcasa-helmchart https://catalogicsoftware.github.io/cloudcasa-helmchart/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="cloudcasa"
CHART="cloudcasa-helmchart/cloudcasa"
CHART_VERSION="2.0.0"
NAMESPACE="default"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/cloudcasa/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/cloudcasa/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
