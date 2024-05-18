#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="easyhaproxy"
NAMESPACE="easyhaproxy"

# Check if there is any node with the label "easyhaproxy/node=master"
master_node_exists=$(kubectl get nodes --selector=easyhaproxy/node=master -o jsonpath='{.items[*].metadata.name}')

# If there is a node with the label, then remove the label
if [ -n "$master_node_exists" ]; then
    kubectl label nodes "$master_node_exists" "easyhaproxy/node-"
fi

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
