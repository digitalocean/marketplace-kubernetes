#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="vijil-dome"
HELM_CHART_URL="oci://ghcr.io/vijilai/helm/vijil-dome"

ROOT_DIR=$(git rev-parse --show-toplevel)
values="$ROOT_DIR/stacks/vijil-dome/values.yml"

helm upgrade "$STACK" "$HELM_CHART_URL" \
  -f "$values"
