#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add ngrok https://ngrok.github.io/kubernetes-ingress-controller
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="ngrok-ingress-controller"
CHART="ngrok/kubernetes-ingress-controller"
CHART_VERSION="0.12.1"
NAMESPACE="ngrok-ingress-controller"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/ngrok-ingress-controller/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/ngrok-ingress-controller/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
