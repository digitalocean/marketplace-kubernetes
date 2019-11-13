#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

# create prometheus-operator namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: prometheus-operator
EOF

# set kubectl namespace
kubectl config set-context --current --namespace=prometheus-operator

# deploy prometheus-operator
kubectl apply -f "$ROOT_DIR"/stacks/prometheus-operator/yaml/prometheus-operator.yaml

# ensure services are running
kubectl rollout status -w deployment/prometheus-operator-grafana
kubectl rollout status -w deployment/prometheus-operator-kube-state-metrics
kubectl rollout status -w deployment/prometheus-operator-operator
