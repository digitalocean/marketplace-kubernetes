#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="vijil-dome"
HELM_CHART_URL="oci://ghcr.io/vijilai/helm/vijil-dome"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/vijil-dome/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/vijil-dome/values.yml"
fi

helm install "$STACK" "$HELM_CHART_URL" \
  -f "$values"
