#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add datawire https://app.getambassador.io --force-update
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="edge-stack"
CHART="datawire/edge-stack"
CHART_VERSION="7.2.2"
NAMESPACE="ambassador"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/ambassador/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/ambassador/values.yml"
fi

# Before installing Ambassador 2.X itself, you must configure your Kubernetes cluster to support the getambassador.io/v3alpha1 and getambassador.io/v2 configuration resources. This is required.
kubectl apply -f https://app.getambassador.io/yaml/edge-stack/2.1.2/aes-crds.yaml

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --version "$CHART_VERSION" \
  --values "$values" \
  --timeout 10m0s
