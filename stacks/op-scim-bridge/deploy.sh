#!/bin/sh

set -e

helm repo add op-scim-bridge https://raw.githubusercontent.com/1Password/op-scim-helm/main/
helm repo update > /dev/null

STACK="op-scim-bridge"
CHART="op-scim-bridge/op-scim"
CHART_VERSION="2.3.1"
NAMESPACE="op-scim-bridge"
STORAGE_CLASS="do-block-storage"

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --install \
  --timeout 8m0s \
  --create-namespace \
  --namespace "$NAMESPACE" \
  --version "$CHART_VERSION" \
  --set scim.credentialsVolume.storageClass="$STORAGE_CLASS"
