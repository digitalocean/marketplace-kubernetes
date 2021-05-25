#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add vectorized https://charts.vectorized.io/
helm repo add jetstack https://charts.jetstack.io
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="redpanda"
CHART="vectorized/redpanda-operator"
CHART_VERSION="v21.5.5"
NAMESPACE="redpanda-system"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/redpanda/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/redpanda/values.yml"
fi

helm upgrade \
  cert-manager jetstack/cert-manager \
  --atomic \
  --create-namespace \
  --install \
  --namespace cert-manager \
  --version v1.2.0 \
  --set installCRDs=true

kubectl apply -k "https://github.com/vectorizedio/redpanda/src/go/k8s/config/crd?ref=$CHART_VERSION"

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"

MAX=50
CURRENT=0

until $(kubectl apply -f "https://raw.githubusercontent.com/vectorizedio/redpanda/$CHART_VERSION/src/go/k8s/config/samples/external_connectivity.yaml" >/dev/null 2>&1); do
  CURRENT=$((CURRENT + 1))
  sleep 1

  if [ "$CURRENT" -gt "$MAX" ]; then
    echo "FAILED: Webhook not ready, giving up."
    exit 1
  fi
done
