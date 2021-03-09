#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add lakefs http://charts.lakefs.io/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="lakefs"
CHART="lakefs/lakefs"
CHART_VERSION="0.5.15"
NAMESPACE="lakefs"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/lakefs/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/lakefs/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
