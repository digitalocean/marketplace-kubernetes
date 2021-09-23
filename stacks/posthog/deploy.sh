#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add posthog https://posthog.github.io/charts-clickhouse/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="posthog"
CHART="posthog/posthog"
NAMESPACE="posthog"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/posthog/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/posthog/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --timeout 20m
