#!/bin/sh

set -e

CHART="ingress-nginx/ingress-nginx"
CHART_VERSION="2.1.0"
NAMESPACE="ingress-nginx"

helm install "$CHART" \
  --create-namespace \
  --generate-name \
  --namespace "$NAMESPACE" \
  --version "$CHART_VERSION" \
  --wait
