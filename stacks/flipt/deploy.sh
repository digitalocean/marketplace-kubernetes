#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add flipt https://helm.flipt.io
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="flipt"
CHART="flipt/flipt"
NAMESPACE="flipt"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/flipt/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/flipt/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
