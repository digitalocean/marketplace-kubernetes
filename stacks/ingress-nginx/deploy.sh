#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="ingress-nginx"
CHART="ingress-nginx/ingress-nginx"
CHART_VERSION="4.11.2"
NAMESPACE="ingress-nginx"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/ingress-nginx/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/ingress-nginx/values.yml"
fi

# A timeout of 10m is needed for the Nginx Helm installation, due to the fact that DO load balancers may take a while to spin up
helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  --timeout 10m0s
