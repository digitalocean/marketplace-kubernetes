#!/bin/sh

set -e

helm repo add op-scim-bridge https://raw.githubusercontent.com/1Password/op-scim-helm/main/
helm repo update > /dev/null

STACK="op-scim-bridge"
CHART="op-scim-bridge/op-scim"
CHART_VERSION="2.1.0"
NAMESPACE="op-scim-bridge"

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --install \
  --create-namespace \
  --namespace "$NAMESPACE" \
  --version "$CHART_VERSION"

