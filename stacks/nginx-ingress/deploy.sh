#!/bin/sh

# https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx

set -e

STACK="nginx-ingress"
CHART="ingress-nginx/ingress-nginx"
CHART_VERSION="2.1.0"
NAMESPACE="ingress-nginx"

if [ -z "${MP_KUBERNETES}" ]; then
  VALUES="values.yaml"
else
  VALUES="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/${STACK}/values.yaml"
fi

helm install "$CHART" \
  --create-namespace \
  --generate-name \
  --namespace "$NAMESPACE" \
  --values "$VALUES" \
  --version "$CHART_VERSION" \
  --wait
