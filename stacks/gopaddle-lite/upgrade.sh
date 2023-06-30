#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add gopaddle https://gopaddle-io.github.io/gopaddle-lite/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="gp-lite-4-2"
CHART="gopaddle/gp-installer"
NAMESPACE="gp-lite-4-2"
CHART_VERSION="4.2.6"


if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/gopaddle-lite/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/gopaddle-lite/values.yml"
fi

# Get the first node's external IP, if it exists
FIRST_NODE_EXT_IP=$(kubectl get nodes -o jsonpath='{$.items[0].status.addresses[?(@.type=="ExternalIP")].address}' 2>/dev/null)

# If there's no external IP, get the internal IP
if [ -z "$FIRST_NODE_EXT_IP" ]; then
        FIRST_NODE_IP=$(kubectl get nodes -o jsonpath='{$.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null)
else
        FIRST_NODE_IP="$FIRST_NODE_EXT_IP"
fi

helm upgrade "$STACK" "$CHART" \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --set global.cluster.nodeIP="$FIRST_NODE_IP" \
  --version "$CHART_VERSION"
