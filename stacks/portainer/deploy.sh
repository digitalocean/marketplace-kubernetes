#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add portainer https://portainer.github.io/k8s/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="portainer"
CHART="portainer/portainer"
CHART_VERSION="1.0.x"
NAMESPACE="portainer"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/portainer/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/portainer/values.yml"
fi

# Create the namespace if it doesn't already exist
kubectl create namespace portainer -o yaml --dry-run | kubectl apply -f -

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
