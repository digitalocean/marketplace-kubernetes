#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add antmedia https://ant-media.github.io/helm
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="antmedia"
CHART="antmedia/antmedia"
CHART_VERSION="2.9.0"
NAMESPACE="antmedia"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/ant-media/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/ant-media/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  --set edge=origin.localhost \
  --set origin=edge.localhost
