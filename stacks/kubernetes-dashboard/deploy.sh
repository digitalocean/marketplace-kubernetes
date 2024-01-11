#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="kubernetes-dashboard"
CHART="kubernetes-dashboard/kubernetes-dashboard"
CHART_VERSION="7.0.0-alpha1"
NAMESPACE="kubernetes-dashboard"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/kubernetes-dashboard/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/kubernetes-dashboard/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \


# We are deliberately commenting out the chart version to install the latest version of the dashboard
#  --version "$CHART_VERSION"
