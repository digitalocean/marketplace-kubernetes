#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

# create namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: loki 
EOF

# set kubectl namespace
kubectl config set-context --current --namespace=loki

# deploy loki 
kubectl apply -f "$ROOT_DIR"/stacks/loki/yaml/loki.yaml

# ensure services are running
kubectl rollout status -w statefulset/loki
