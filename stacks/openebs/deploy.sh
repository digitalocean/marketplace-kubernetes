#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add openebs https://openebs.github.io/charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="openebs"
CHART="openebs/openebs"
CHART_VERSION="2.12.0"
NAMESPACE="openebs"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  VALUES="$ROOT_DIR/stacks/${STACK}/values.yml"
else
  # use github hosted master version of values.yml
  VALUES="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/${STACK}/values.yaml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
