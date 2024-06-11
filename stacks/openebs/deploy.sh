#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add --force-update openebs https://openebs.github.io/openebs
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="openebs"
CHART="openebs/openebs"
NAMESPACE="openebs"
CHART_VERSION="4.0.1"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  VALUES="$ROOT_DIR/stacks/${STACK}/values.yml"
else
  # use github hosted master version of values.yml
  VALUES="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/${STACK}/values.yaml"
fi

helm upgrade "$STACK" "$CHART" \
  --create-namespace \
  --install \
  --set openebs-crds.csi.volumeSnapshots.enabled=false \
  --timeout 20m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
