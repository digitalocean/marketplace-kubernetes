#!/bin/sh

set -e

# create prometheus namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: prometheus
EOF

# create grafana namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: grafana
EOF

ROOT_DIR=$(git rev-parse --show-toplevel)

# deploy prometheus
kubectl -n prometheus apply -f \
  "$ROOT_DIR"/stacks/1/yaml/prometheus.yaml

# ensure prometheus is running
kubectl -n prometheus rollout status deployment/prometheus-server

# deploy grafana dashboards
kubectl -n grafana apply -f \
  "$ROOT_DIR"/stacks/1/yaml/k8s-mixin-dashboards.yaml

# deploy grafana
kubectl -n grafana apply -f \
  "$ROOT_DIR"/stacks/1/yaml/grafana.yaml

# ensure grafana is running
kubectl -n grafana rollout status deployment/grafana
