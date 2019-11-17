#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

# set kubectl namespace
kubectl config set-context --current --namespace=kube-system

# deploy kube-state-metrics
kubectl apply -f "$ROOT_DIR"/stacks/kube-state-metrics/yaml/kube-state-metrics.yaml

# ensure services are running
kubectl rollout status -w deployment/kube-state-metrics
