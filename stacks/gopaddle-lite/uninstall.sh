#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="gp-lite-4-2"
NAMESPACE="gp-lite-4-2"

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

kubectl delete -f "$clusterrole"
kubectl delete -f "$clusterrolebinding"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
