#!/bin/sh

set -e

STACK="kube-state-metrics"
CHART="stable/kube-state-metrics"
CHART_VERSION="2.8.4"
NAMESPACE="kube-system"

if [ -z "${MP_KUBERNETES}" ]; then
  values="values.yaml"
else
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/${STACK}/values.yaml"
fi

helm install "$CHART" \
  --create-namespace \
  --generate-name \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  --wait