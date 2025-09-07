#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="kube-state-metrics"
CHART="prometheus-community/kube-state-metrics"
CHART_VERSION="6.3.0"
NAMESPACE="kube-state-metrics"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/kube-state-metrics/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/kube-state-metrics/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --install \
  --create-namespace \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  --wait
