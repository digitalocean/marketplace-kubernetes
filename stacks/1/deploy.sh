#!/bin/sh

set -e 

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
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/package_prometheus_grafana/stacks/1/yaml/prometheus.yaml?token=AHIGBPHKOYBL6EDHYW3GMRS5CIP6W -n prometheus
#grafana
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/package_prometheus_grafana/stacks/1/yaml/grafana.yaml?token=AHIGBPA77LSWUNDJ4XR3ECS5CIP36 -n grafana
