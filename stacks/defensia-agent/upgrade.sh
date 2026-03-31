#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="defensia-agent"
HELM_CHART_URL="oci://ghcr.io/defensia/charts/defensia-agent"
CHART_VERSION="0.4.1"
NAMESPACE="defensia"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/defensia-agent/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/defensia-agent/values.yml"
fi

helm upgrade "$STACK" "$HELM_CHART_URL" \
  --atomic \
  --install \
  --create-namespace \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --version "$CHART_VERSION" \
  -f "$values"
