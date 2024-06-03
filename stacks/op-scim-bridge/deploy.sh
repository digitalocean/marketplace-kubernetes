#!/bin/sh

set -e

REPO_URL="https://1password.github.io/op-scim-helm"
REPO_NAME="1password"

helm repo add "$REPO_NAME" "$REPO_URL"
helm repo update > /dev/null

CHART_NAME="op-scim-bridge"
CHART_VERSION="2.11.4"

RELEASE="op-scim-bridge"
NAMESPACE="op-scim-bridge"
STORAGE_CLASS="do-block-storage"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  VALUES_FILE="$ROOT_DIR/stacks/op-scim-bridge/values.yml"
else
  # use github hosted master version of values.yml
  VALUES_FILE="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/op-scim-bridge/values.yml"
fi

helm upgrade "$RELEASE" "$REPO_NAME/$CHART_NAME" \
  --atomic \
  --install \
  --timeout 8m0s \
  --create-namespace \
  --namespace "$NAMESPACE" \
  --version "$CHART_VERSION" \
  --values "$VALUES_FILE" 
