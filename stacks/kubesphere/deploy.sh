#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add main https://charts.kubesphere.io/main
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="kubesphere"
CHART="main/ks-installer"
CHART_VERSION="0.2.2"
NAMESPACE="kubesphere-system"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  VALUES="$ROOT_DIR/stacks/${STACK}/values.yml"
else
  # use github hosted master version of values.yml
  VALUES="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/${STACK}/values.yaml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
