#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

# set kubectl namespace
kubectl config set-context --current --namespace=kube-system

# deploy metrics-server
kubectl apply -f "$ROOT_DIR"/stacks/metrics-server/yaml/metrics-server.yaml

# ensure services are running
kubectl rollout status -w deployment/metrics-server
