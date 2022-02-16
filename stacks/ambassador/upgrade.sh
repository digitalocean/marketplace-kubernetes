#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add datawire https://app.getambassador.io
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="edge-stack"
CHART="datawire/edge-stack"
NAMESPACE="ambassador"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/ambassador/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/ambassador/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
