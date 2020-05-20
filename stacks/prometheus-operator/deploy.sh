#!/bin/sh

set -e

STACK="prometheus-operator"
CHART="stable/prometheus-operator"
CHART_VERSION="8.13.7"
NAMESPACE="prometheus-operator"

if [ -z "${MP_KUBERNETES}" ]; then
  VALUES="values.yaml"
else
  VALUES="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/${STACK}/values.yaml"
fi

helm upgrade "$STACK" "$CHART" \
  --install \
  --create-namespace \
  --namespace "$NAMESPACE" \
  --values "$VALUES" \
  --version "$CHART_VERSION" \
  --wait
