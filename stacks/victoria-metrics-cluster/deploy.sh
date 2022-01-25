#!/bin/sh

set -e

################################################################################
# Add VictoriaMetrics Helm repository
################################################################################
helm repo add vm https://victoriametrics.github.io/helm-charts/
helm repo update > /dev/null

################################################################################
# Install vmoperator from the Helm chart
################################################################################
helm install -n default vmoperator vm/victoria-metrics-operator

# Install VictoriaMetrics Cluster with CRDs
if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  VMCLUSTER="$ROOT_DIR/stacks/victoria-metrics-cluster/yaml/vmcluster.yaml"
  VMAGENT="$ROOT_DIR/stacks/victoria-metrics-cluster/yaml/vmagent.yaml"
  kubectl apply -f "$VMCLUSTER"
  kubectl apply -f "$VMAGENT"
else
  # use github hosted master version of values.yml
  kubectl apply -n default -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/victoria-metrics-cluster/yaml/vmcluster.yaml
  kubectl apply -n default -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/victoria-metrics-cluster/yaml/vmagent.yaml
fi
