#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="simple-host-enterprise"
# Pinned by content digest (chart 0.2.5). Needs Helm 3.17 or later, or Helm 4.
CHART="oci://ghcr.io/vineetu/charts/simple-host-enterprise@sha256:6c8c64c517e79033d5388437d7528b1b4903af9809f37ef93dfc2c2c8fbf10e4"
NAMESPACE="simple-host"

# Keeps the settings given after install and takes the new chart's defaults,
# the image digest among them, for everything else. Needs Helm 3.14 or later.
helm upgrade "$STACK" "$CHART" \
  --namespace "$NAMESPACE" \
  --reset-then-reuse-values \
  --timeout 10m
