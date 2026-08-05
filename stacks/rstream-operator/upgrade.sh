#!/bin/sh

set -eu

STACK="rstream-operator"
CHART="oci://ghcr.io/rstreamlabs/rstream-operator"
CHART_VERSION="0.5.1"
NAMESPACE="rstream-system"

if [ -z "${MP_KUBERNETES:-}" ]; then
  ROOT_DIR=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/rstream-operator/values.yml"
else
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/rstream-operator/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
