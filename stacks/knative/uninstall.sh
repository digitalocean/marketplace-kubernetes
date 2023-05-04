#!/bin/sh

set -e

OPERATOR_VERSION="1.10.0"

kubectl delete --ignore-not-found=true -f "https://github.com/knative/serving/releases/download/knative-v${OPERATOR_VERSION}/serving-crds.yaml"
kubectl delete --ignore-not-found=true -f "https://github.com/knative/net-kourier/releases/download/knative-v${OPERATOR_VERSION}/kourier.yaml"

kubectl delete --ignore-not-found=true -f "https://github.com/knative/eventing/releases/download/knative-v${OPERATOR_VERSION}/eventing-crds.yaml"
kubectl delete --ignore-not-found=true -f "https://github.com/knative/eventing/releases/download/knative-v${OPERATOR_VERSION}/eventing-core.yaml"

kubectl delete --ignore-not-found=true -f "https://github.com/knative/eventing/releases/download/knative-v${OPERATOR_VERSION}/mt-channel-broker.yaml"

# Remove Knative Operator
kubectl delete --ignore-not-found=true -f "https://github.com/knative/operator/releases/download/knative-v${OPERATOR_VERSION}/operator.yaml" --wait
