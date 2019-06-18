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

# deploy prometheus
kubectl -n prometheus apply -f \
  https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/package_prometheus_grafana/stacks/1/yaml/prometheus.yaml?token=AHIGBPHKOYBL6EDHYW3GMRS5CIP6W

# deploy grafana dashboards
kubectl -n grafana apply -f \
  https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/package_prometheus_grafana/stacks/1/yaml/k8s-mixin-dashboards.yaml

# deploy grafana
kubectl -n grafana apply -f \
  https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/package_prometheus_grafana/stacks/1/yaml/grafana.yaml?token=AHIGBPA77LSWUNDJ4XR3ECS5CIP36
