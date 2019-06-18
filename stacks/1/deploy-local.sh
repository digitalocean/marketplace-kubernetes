#!/bin/sh

set -e

# create prometheus-operator namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: prometheus-operator
EOF

ROOT_DIR=$(git rev-parse --show-toplevel)

# deploy prometheus-operator
kubectl -n prometheus-operator apply -f \
  "$ROOT_DIR"/stacks/1/yaml/prometheus-operator.yaml

# ensure services are running
kubectl -n prometheus-operator rollout status deployment/prometheus-operator-grafana
kubectl -n prometheus-operator rollout status deployment/prometheus-operator-kube-state-metrics
kubectl -n prometheus-operator rollout status deployment/prometheus-operator-operator
