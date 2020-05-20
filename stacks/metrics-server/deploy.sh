#!/bin/sh

STACK="metrics-server"
CHART="stable/metrics-server"
CHART_VERSION="2.11.1"
NAMESPACE="kube-system"

helm status $STACK -n $NAMESPACE 
if [ $? -eq 0 ]; then
  echo "${CHART} is already installed."
  exit 0
fi

if [ -z "${MP_KUBERNETES}" ]; then
  VALUES="values.yaml"
else
  VALUES="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/${STACK}/values.yaml"
fi

helm install "$STACK" "$CHART" \
  --create-namespace \
  --namespace "$NAMESPACE" \
  --values "$VALUES" \
  --version "$CHART_VERSION" \
  --wait

if [ $? -eq 0 ]; then
  exit 0
else
  exit 1
fi
