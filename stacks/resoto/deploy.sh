#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add someengineering https://helm.some.engineering
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="resoto"
CHART="someengineering/resoto"
NAMESPACE="resoto"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/resoto/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/resoto/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --timeout 20m
