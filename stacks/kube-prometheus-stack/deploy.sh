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
STACK="kube-prometheus-stack"
CHART="prometheus-community/kube-prometheus-stack"
CHART_VERSION="18.0.0"
NAMESPACE="kube-prometheus-stack"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/kube-prometheus-stack/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/kube-prometheus-stack/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
