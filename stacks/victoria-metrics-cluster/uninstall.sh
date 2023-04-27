#!/bin/sh

set -e

STACK="vmoperator"
NAMESPACE="default"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"

# Uninstall VictoriaMetrics Cluster
if [ -z "${MP_KUBERNETES}" ]; then
  # with local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  VMCLUSTER="$ROOT_DIR/stacks/victoria-metrics-cluster/yaml/vmcluster.yaml"
  VMAGENT="$ROOT_DIR/stacks/victoria-metrics-cluster/yaml/vmagent.yaml"
  kubectl delete -f "$VMCLUSTER"
  kubectl delete -f "$VMAGENT"
else
  # with github hosted master version of values.yml
  kubectl delete -n default -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/victoria-metrics-cluster/yaml/vmcluster.yaml
  kubectl delete -n default -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/victoria-metrics-cluster/yaml/vmagent.yaml
fi
