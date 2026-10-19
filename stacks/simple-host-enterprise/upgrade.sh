#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="simple-host-enterprise"
CHART_REF="oci://ghcr.io/vineetu/charts/simple-host-enterprise"
CHART_VERSION="0.2.5"
# Pinned by content digest. The tag is only used to fetch; the install aborts
# unless the pulled chart has exactly this digest.
CHART_DIGEST="sha256:6c8c64c517e79033d5388437d7528b1b4903af9809f37ef93dfc2c2c8fbf10e4"
CHART_DIR="$(mktemp -d)"
trap 'rm -rf "$CHART_DIR"' EXIT
pulled_digest="$(helm pull "$CHART_REF" --version "$CHART_VERSION" --destination "$CHART_DIR" 2>&1 | sed -n 's/^Digest: //p')"
if [ "$pulled_digest" != "$CHART_DIGEST" ]; then
  echo "chart digest mismatch: expected $CHART_DIGEST, got ${pulled_digest:-none}" >&2
  exit 1
fi
CHART="$CHART_DIR/simple-host-enterprise-$CHART_VERSION.tgz"
NAMESPACE="simple-host"

# Keeps the settings given after install and takes the new chart's defaults,
# the image digest among them, for everything else. Needs Helm 3.14 or later.
helm upgrade "$STACK" "$CHART" \
  --namespace "$NAMESPACE" \
  --reset-then-reuse-values \
  --timeout 10m
