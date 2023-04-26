#!/bin/sh

set -e

OPERATOR_VERSION="1.5.1"

# Remove Knative Serving and Eventing resources first
kubectl delete KnativeServing knative-serving -n knative-serving
kubectl delete KnativeEventing knative-eventing -n knative-eventing

# Remove Knative Operator
kubectl delete -f "https://github.com/knative/operator/releases/download/knative-v${OPERATOR_VERSION}/operator.yaml"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
