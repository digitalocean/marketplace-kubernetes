#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add traefik https://traefik.github.io/charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="traefik"
CHART="traefik/traefik"
CHART_VERSION="37.4.0"
NAMESPACE="traefik"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/traefik/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/traefik/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
