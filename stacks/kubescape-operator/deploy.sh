#!/bin/sh

set -ex

################################################################################
# repo
################################################################################
helm repo add kubescape https://kubescape.github.io/helm-charts/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="kubescape-operator"
CHART="kubescape/kubescape-operator"
CHART_VERSION="1.18.13"
NAMESPACE="kubescape"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/kubescape-operator/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/kubescape-operator/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  --set clusterName=$(kubectl config current-context)
