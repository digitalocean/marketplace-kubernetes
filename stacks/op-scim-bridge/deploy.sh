#!/bin/sh

set -e

REPO_URL="https://1password.github.io/op-scim-helm"
REPO_NAME="1password"

helm repo add "$REPO_NAME" "$REPO_URL"
helm repo update > /dev/null

CHART_NAME="op-scim-bridge"
CHART_VERSION="2.9.1"

RELEASE="op-scim-bridge"
NAMESPACE="op-scim-bridge"
STORAGE_CLASS="do-block-storage"

helm upgrade "$RELEASE" "$REPO_NAME/$CHART_NAME" \
  --atomic \
  --install \
  --timeout 8m0s \
  --create-namespace \
  --namespace "$NAMESPACE" \
  --version "$CHART_VERSION" \
  --set scim.credentialsVolume.storageClass="$STORAGE_CLASS"
