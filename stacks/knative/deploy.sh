#!/bin/sh

set -e

OPERATOR_VERSION="1.11.6"

kubectl apply -f "https://github.com/knative/serving/releases/download/knative-v${OPERATOR_VERSION}/serving-crds.yaml"
kubectl apply -f "https://github.com/knative/serving/releases/download/knative-v${OPERATOR_VERSION}/serving-core.yaml"
kubectl apply -f "https://github.com/knative/net-kourier/releases/download/knative-v${OPERATOR_VERSION}/kourier.yaml"
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'

kubectl apply -f "https://github.com/knative/eventing/releases/download/knative-v${OPERATOR_VERSION}/eventing-crds.yaml"
kubectl apply -f "https://github.com/knative/eventing/releases/download/knative-v${OPERATOR_VERSION}/eventing-core.yaml"

kubectl apply -f "https://github.com/knative/eventing/releases/download/knative-v${OPERATOR_VERSION}/mt-channel-broker.yaml"

# Deploy Knative Operator
kubectl apply -f "https://github.com/knative/operator/releases/download/knative-v${OPERATOR_VERSION}/operator.yaml" --wait
