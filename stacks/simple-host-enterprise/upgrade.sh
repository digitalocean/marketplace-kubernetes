#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="simple-host-enterprise"
CHART="${CHART:-oci://ghcr.io/vineetu/charts/simple-host-enterprise}"
CHART_VERSION="0.2.1"
NAMESPACE="simple-host"

# Keeps the settings given after install and takes the new chart's defaults,
# the image digest among them, for everything else. Needs Helm 3.14 or later.
helm upgrade "$STACK" "$CHART" \
  --namespace "$NAMESPACE" \
  --version "$CHART_VERSION" \
  --reset-then-reuse-values \
  --timeout 10m
