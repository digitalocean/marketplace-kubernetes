#!/bin/sh

set -e

# create namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: op-scim-bridge
EOF

# set kubectl namespace
kubectl config set-context --current --namespace=op-scim-bridge

# deploy op-scim-bridge
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/op-scim-bridge/yaml/op-scim-bridge.yaml

# ensure services are running
kubectl rollout status -w deployment/op-scim-bridge
