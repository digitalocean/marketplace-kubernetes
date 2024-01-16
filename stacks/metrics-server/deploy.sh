#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="metrics-server"
CHART="metrics-server/metrics-server"
CHART_VERSION="3.11.0"
NAMESPACE="metrics-server"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/metrics-server/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/metrics-server/values.yml"
fi

if helm history "${STACK}" -n "${NAMESPACE}" | grep -q 'pending-install'; then
   echo "another installation is in progress, sleeping for 30 seconds"
   sleep 30
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
