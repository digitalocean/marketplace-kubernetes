#!/bin/sh

set -e

STACK="jaeger"
CHART="jaegertracing/jaeger"
CHART_VERSION="0.28.0"
NAMESPACE="jaeger"


helm repo add jaegertracing https://jaegertracing.github.io/helm-charts --force-update
helm repo update > /dev/null

if [ -z "${MP_KUBERNETES}" ]; then
  VALUES="values.yaml"
else
  VALUES="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/${STACK}/values.yaml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --namespace "$NAMESPACE" \
  --values "$VALUES" \
  --version "$CHART_VERSION" \
  --wait
