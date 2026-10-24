#!/bin/sh

set -eu

################################################################################
# chart
################################################################################
STACK="stackradar"
CHART="oci://ghcr.io/lockdep/helm-charts/stackradar"
CHART_VERSION="0.2.0"
NAMESPACE="stackradar"

if [ -z "${MP_KUBERNETES:-}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/stackradar/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/stackradar/values.yml"
fi

# --reuse-values keeps the secrets deploy.sh generated at install time.
# Chart-level breaking changes between versions are listed in
# https://github.com/lockdep/helm-charts/blob/main/charts/stackradar/UPGRADING.md
helm upgrade "$STACK" "$CHART" \
  --atomic \
  --timeout 15m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  --reuse-values
