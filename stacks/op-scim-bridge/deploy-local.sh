#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

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
kubectl apply -f "$ROOT_DIR"/stacks/op-scim-bridge/yaml/op-scim-bridge.yaml

# ensure services are running
kubectl rollout status -w deployment/op-scim-bridge
