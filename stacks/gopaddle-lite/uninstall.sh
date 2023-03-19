#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="gp-lite-4-2"
NAMESPACE="gp-lite-4-2"
ADDON_NAMESPACE="gopaddle-servers"
ADDON_CLUSTER_ROLE="gopaddle:nginx-ingress-clusterrole"
ADDON_CLUSTER_ROLEBINDING="gopaddle:event-exporter-rb"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  clusterrole="$ROOT_DIR/stacks/gopaddle-lite/clusterrole.yaml"
  clusterrolebinding="$ROOT_DIR/stacks/gopaddle-lite/clusterrolebinding.yaml"
else
  # use github hosted master version of values.yml
  clusterrole="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/gopaddle-lite/clusterrole.yaml"
  clusterrolebinding="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/gopaddle-lite/clusterrolebinding.yaml"
fi

kubectl delete -f "$clusterrole" --ignore-not-found=true
kubectl delete -f "$clusterrolebinding" --ignore-not-found=true

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"

kubectl delete ns "$NAMESPACE" --ignore-not-found=true
kubectl delete ns "$ADDON_NAMESPACE" --ignore-not-found=true
kubectl delete clusterrole "$ADDON_CLUSTER_ROLE" --ignore-not-found=true
kubectl delete clusterrolebinding "$ADDON_CLUSTER_ROLEBINDING" --ignore-not-found=true

