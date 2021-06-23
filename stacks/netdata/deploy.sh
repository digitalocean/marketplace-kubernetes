#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add netdata https://netdata.github.io/helmchart
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="netdata"
CHART="netdata/netdata"
CHART_VERSION="3.6.7"
NAMESPACE="netdata"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/netdata/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/netdata/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
