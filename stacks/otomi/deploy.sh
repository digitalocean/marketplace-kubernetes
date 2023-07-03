#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add otomi https://otomi.io/otomi-core
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="otomi"
CHART="otomi/otomi"
NAMESPACE="default"
VERSION="1.24"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/otomi/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/otomi/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --set cluster.k8sVersion="$VERSION" \
  --values "$values" 
