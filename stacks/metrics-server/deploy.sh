#!/bin/sh

set -e

# check if metrics-server is already installed
CHECK=$(kubectl get svc metrics-server -n kube-system --ignore-not-found)
if [ "$CHECK" = "" ]
then
  echo "metrics-server not found"
else
  echo "metrics-server found, exiting"
  exit 0
fi

# install metrics-server
STACK="metrics-server"
CHART="stable/metrics-server"
CHART_VERSION="2.11.1"
NAMESPACE="kube-system"

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
