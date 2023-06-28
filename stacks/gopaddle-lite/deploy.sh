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
CHART_VERSION="4.2.6"
NAMESPACE="gp-lite-4-2"

#if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
#  ROOT_DIR=$(git rev-parse --show-toplevel)
#  values="$ROOT_DIR/stacks/gopaddle-lite/values.yml"
#  clusterrole="$ROOT_DIR/stacks/gopaddle-lite/clusterrole.yaml"
#  clusterrolebinding="$ROOT_DIR/stacks/gopaddle-lite/clusterrolebinding.yaml"
#else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/gopaddle-lite/values.yml"
  clusterrole="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/gopaddle-lite/clusterrole.yaml"
  clusterrolebinding="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/gopaddle-lite/clusterrolebinding.yaml"
#fi

kubectl apply -f "$clusterrole"
kubectl apply -f "$clusterrolebinding"

# Get the first node's external IP, if it exists
FIRST_NODE_EXT_IP=$(kubectl get nodes -o json | jq -r '.items[0].status.addresses[] | select(.type=="ExternalIP") | .address' 2>/dev/null)

# If there's no external IP, get the internal IP
if [ -z "$FIRST_NODE_EXT_IP" ]; then
        FIRST_NODE_IP=$(kubectl get nodes -o json | jq -r '.items[0].status.addresses[] | select(.type=="InternalIP") | .address')
else
        FIRST_NODE_IP="$FIRST_NODE_EXT_IP"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 15m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --set global.cluster.nodeIP="$FIRST_NODE_IP" \
  --version "$CHART_VERSION"
