#!/bin/sh

set -e

CHART="stable/kube-state-metrics"
CHART_VERSION="2.8.4"
NAMESPACE="kube-system"

helm install "$CHART" \
  --create-namespace \
  --generate-name \
  --namespace "$NAMESPACE" \
  --values values.yaml \
  --version "$CHART_VERSION" \
  --wait
