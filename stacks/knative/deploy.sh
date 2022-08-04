#!/bin/sh

set -e

OPERATOR_VERSION="1.5.1"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of knative serving and eventing manifests
  ROOT_DIR=$(git rev-parse --show-toplevel)
  KNATIVE_SERVING_COMPONENT="$ROOT_DIR/stacks/knative/assets/manifests/knative-serving.yaml"
  KNATIVE_EVENTING_COMPONENT="$ROOT_DIR/stacks/knative/assets/manifests/knative-eventing.yaml"
else
  # use github hosted master version of knative serving and eventing manifests
  KNATIVE_SERVING_COMPONENT="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/knative/assets/manifests/knative-serving.yaml"
  KNATIVE_EVENTING_COMPONENT="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/knative/assets/manifests/knative-eventing.yaml"
fi

# Deploy Knative Operator
kubectl apply -f "https://github.com/knative/operator/releases/download/knative-v${OPERATOR_VERSION}/operator.yaml" --wait

# Deploy Knative Serving and Eventing components
kubectl apply -f "$KNATIVE_SERVING_COMPONENT"
kubectl apply -f "$KNATIVE_EVENTING_COMPONENT"
