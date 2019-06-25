#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

# create prometheus-operator namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: logging
EOF

# set kubectl namespace
kubectl config set-context --current --namespace=logging

# deploy prometheus-operator
kubectl apply -f "$ROOT_DIR"/stacks/2/yaml/fluent-bit.yaml
kubectl apply -f "$ROOT_DIR"/stacks/2/yaml/fluentd.yaml

# ensure services are running
kubectl rollout status daemonset/fluent-bit
kubectl rollout status deployment/fluentd
