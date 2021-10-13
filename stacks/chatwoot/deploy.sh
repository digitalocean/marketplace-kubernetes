#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add chatwoot https://chatwoot.github.io/charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="chatwoot"
CHART="chatwoot/chatwoot"
NAMESPACE="chatwoot"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/chatwoot/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/chatwoot/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --timeout 10m
