#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

# deploy linkerd2
kubectl apply -f "$ROOT_DIR"/stacks/linkerd2/yaml/linkerd2.yaml

# ensure services are running
kubectl get deployments -o custom-columns=NAME:.metadata.name | tail -n +2 | while read -r line
do
  kubectl rollout status -w deployment/"$line"
done
