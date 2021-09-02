#!/bin/sh

set -e
set -x
################################################################################
# chart
################################################################################
STACK="redpanda"
NAMESPACE="redpanda-system"
CHART_VERSION="v21.8.1"

kubectl delete -f "https://raw.githubusercontent.com/vectorizedio/redpanda/v21.8.1/src/go/k8s/config/samples/external_connectivity.yaml"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"

kubectl delete -k "https://github.com/vectorizedio/redpanda/src/go/k8s/config/crd?ref=$CHART_VERSION"

helm uninstall prometheus-operator\
  --namespace monitoring

helm uninstall cert-manager \
  --namespace cert-manager
