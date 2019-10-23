#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

# create namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: redskyops
EOF

# set kubectl namespace
kubectl config set-context --current --namespace=redskyops

# deploy redskyops
kubectl apply -f "$ROOT_DIR"/stacks/redskyops/yaml/redskyops.yaml

# ensure services are running
kubectl rollout status deployment/redskyops-controller-manager
