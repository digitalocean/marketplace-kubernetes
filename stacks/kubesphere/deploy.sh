#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="kubesphere"
KUBESPHERE_VERSION="4.1.3"
NAMESPACE="kubesphere-system"

CHART_DIR=$(mktemp -d)
trap 'rm -rf "$CHART_DIR"' 0
curl -fsSL "https://github.com/kubesphere/kubesphere/archive/refs/tags/v${KUBESPHERE_VERSION}.tar.gz" \
  --output "$CHART_DIR/source.tar.gz"
tar -xzf "$CHART_DIR/source.tar.gz" -C "$CHART_DIR" --strip-components=3 \
  "kubesphere-${KUBESPHERE_VERSION}/config/ks-core"
rm "$CHART_DIR/source.tar.gz"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  VALUES="$ROOT_DIR/stacks/${STACK}/values.yml"
else
  # use github hosted master version of values.yml
  VALUES="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/${STACK}/values.yml"
fi

helm upgrade "$STACK" "$CHART_DIR" \
  --atomic \
  --cleanup-on-fail \
  --wait --timeout 10m \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$VALUES"
