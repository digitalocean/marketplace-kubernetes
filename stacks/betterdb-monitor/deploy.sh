#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add betterdb https://docs.betterdb.com/charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="betterdb-monitor"
CHART="betterdb/betterdb-monitor"
CHART_VERSION="0.40.0"
NAMESPACE="betterdb-monitor"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/betterdb-monitor/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/betterdb-monitor/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
