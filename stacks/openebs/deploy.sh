#!/bin/sh

set -e

STACK="openebs"
CHART="stable/openebs"
CHART_VERSION="1.9.2"
NAMESPACE="openebs"

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

#helm install stable/openebs --version 1.9.2