#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

# create moon namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: moon
EOF

# set kubectl namespace
kubectl config set-context --current --namespace=moon

# deploy moon
kubectl apply -f "$ROOT_DIR"/stacks/moon/yaml/moon.yaml

# ensure services are running
kubectl rollout status -w deployment/moon
