#!/bin/sh

set -e

STACK="op-scim-bridge"
#figure out what CHART value should be
CHART="stable/kube-state-metrics"
CHART_VERSION="1.4.2"
NAMESPACE="op-scim-bridge"

if [ -z "${MP_KUBERNETES}" ]; then
  VALUES="values.yaml"
else
  VALUES="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/${STACK}/values.yaml"
fi

helm upgrade "$STACK" "$CHART" \
  --install \
  --create-namespace \
  --generate-name \
  --namespace "$NAMESPACE" \
  --values "$VALUES" \
  --version "$CHART_VERSION" \
  --wait