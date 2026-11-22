#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add denpex https://denpex.com/charts --force-update
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="denpex-gpu-watcher"
CHART="denpex/denpex-gpu-watcher"
NAMESPACE="denpex-gpu-watcher"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/denpex-gpu-watcher/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/denpex-gpu-watcher/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --namespace "$NAMESPACE" \
  --values "$values"
