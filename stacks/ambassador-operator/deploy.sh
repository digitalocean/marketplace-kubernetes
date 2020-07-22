#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add datawire https://getambassador.io
helm repo update

################################################################################
# chart
################################################################################
STACK="ambassador"
CHART="datawire/ambassador"
NAMESPACE="ambassador"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/ambassador/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/ambassadorvalues.yml"
fi

kubectl apply -f https://getambassador.io/yaml/aes-crds.yaml

helm upgrade "$STACK" "$CHART" \
  --install \
  --create-namespace \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --wait