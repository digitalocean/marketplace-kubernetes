#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

# set kubectl namespace
kubectl config set-context --current --namespace=kube-system

# deploy metrics-server
kubectl apply -f "$ROOT_DIR"/stacks/3/yaml/metrics-server.yaml

# ensure services are running
kubectl rollout status deployment/metrics-server
