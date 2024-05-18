#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add byjg https://opensource.byjg.com/helm
helm repo update > /dev/null

################################################################################
# Pre-requisites
################################################################################

# Check if there is any node with the label "easyhaproxy/node=master"
master_node_exists=$(kubectl get nodes --selector=easyhaproxy/node=master -o jsonpath='{.items[*].metadata.name}')

# If there is no node with the label, then label the first node
if [ -z "$master_node_exists" ]; then
    masternode=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
    kubectl label nodes "$masternode" "easyhaproxy/node=master" --overwrite
fi

################################################################################
# chart
################################################################################
STACK="easyhaproxy"
CHART="byjg/easyhaproxy"
CHART_VERSION="0.1.7"
NAMESPACE="easyhaproxy"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/easyhaproxy/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/easyhaproxy/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
