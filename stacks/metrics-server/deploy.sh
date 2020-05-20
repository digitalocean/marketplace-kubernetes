#!/bin/sh

set -e

STACK="metrics-server"
CHART="stable/metrics-server"
CHART_VERSION="2.11.1"
NAMESPACE="kube-system"

if [ -z "${MP_KUBERNETES}" ]; then
  VALUES="values.yaml"
else
  VALUES="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/${STACK}/values.yaml"
fi

helm upgrade --install "$STACK" "$CHART" \
  --create-namespace \
  --namespace "$NAMESPACE" \
  --values "$VALUES" \
  --version "$CHART_VERSION" \
  --wait