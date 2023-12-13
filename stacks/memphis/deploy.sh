#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add memphis https://k8s.memphis.dev/charts/ 
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="memphis"
CHART="memphis/memphis"
CHART_VERSION="1.4.0"
NAMESPACE="memphis"

values="https://raw.githubusercontent.com/memphisdev/memphis-k8s/gh-pages/memphis/values.yaml"

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  --set memphis.source=digitalocean
