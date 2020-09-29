#!/bin/sh

set -e

export APP_INSTANCE_NAME=k8s-monitor;
export NAMESPACE=k8s-monitor;
export GRAFANA_GENERATED_PASSWORD="$(echo -n 'k8s-monitor-pass' | base64)";

# create namespace
# kubectl create namespace "$NAMESPACE";

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: k8s-monitor 
EOF

# deploy k8s-monitor-stack 
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"

# expose grafana on localhost:4000
# kubectl -n k8s-monitor port-forward k8s-monitor-grafana-0 4000:3000

#login grafana at localhost:4000 id: admin, password: k8s-monitor-pass

#Dashborad Mange Kubernetes/Node


# based on How To Set Up a Kubernetes Monitoring Stack with Prometheus, Grafana and Alertmanager on DigitalOcean
# https://www.digitalocean.com/community/tutorials/how-to-set-up-a-kubernetes-monitoring-stack-with-prometheus-grafana-and-alertmanager-on-digitalocean
