#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add sosivio https://helm.sosiv.io
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="sosivio"
CHART="sosivio/sosivio"
CHART_VERSION="1.5.2"
NAMESPACE="sosivio"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/sosivio/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/sosivio/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --version "$CHART_VERSION" \
  --set expose=PortForward
