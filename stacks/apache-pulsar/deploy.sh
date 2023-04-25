#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add apache https://pulsar.apache.org/charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="apache-pulsar"
CHART="apache/pulsar"
CHART_VERSION="3.0.0"
NAMESPACE="pulsar"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/apache-pulsar/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/apache-pulsar/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --create-namespace \
  --install \
  --timeout 10m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  --set initialize=true
