#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add byjg https://opensource.byjg.com/helm
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="easyhaproxy"
CHART="byjg/easyhaproxy"
CHART_VERSION="2.0.6"
NAMESPACE="easyhaproxy"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/easyhaproxy/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/easyhaproxy/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
