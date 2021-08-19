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

################################################################################
# repo
################################################################################
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="metrics-server"
CHART="bitnami/metrics-server"
CHART_VERSION="5.9.2"
NAMESPACE="kube-system"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/metrics-server/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/metrics-server/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
