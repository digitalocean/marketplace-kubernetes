#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

# deploy metrics-server
kubectl apply -f "$ROOT_DIR"/stacks/3/yaml/.

# ensure services are running
kubectl rollout status deployment/metrics-server -n kube-system

