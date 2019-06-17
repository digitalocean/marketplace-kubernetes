#!/bin/sh

set -e 

ROOT_DIR=$(git rev-parse --show-toplevel)

#creating prometheus namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: prometheus
EOF

#creating grafana namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: grafana
EOF

#spinning up the solution stack
#prometheus
kubectl apply -f "$ROOT_DIR"/stacks/1/yaml/prometheus.yaml -n prometheus
#grafana
kubectl apply -f "$ROOT_DIR"/stacks/1/yaml/grafana.yaml -n grafana
