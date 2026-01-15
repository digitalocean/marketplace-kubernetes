#!/bin/sh

set -e

# Define the repository
OPERATOR_REPO="knative/operator"
EVENTING_REPO="knative/eventing"
SERVING_REPO="knative/serving"
KOURIER_REPO="knative-extensions/net-kourier"

# Fetch the latest release tag name from GitHub API
OPERATOR_VERSION=$(curl -s "https://api.github.com/repos/$OPERATOR_REPO/releases/latest" | \
    grep '"tag_name":' | \
    sed -E 's/.*"([^"]+)".*/\1/' | \
    sed 's/^knative-v//' | \
    sed 's/^v//')

KOURIER_VERSION=$(curl -s "https://api.github.com/repos/$KOURIER_REPO/releases/latest" | \
    grep '"tag_name":' | \
    sed -E 's/.*"([^"]+)".*/\1/' | \
    sed 's/^knative-v//' | \
    sed 's/^v//')

SERVING_VERSION=$(curl -s "https://api.github.com/repos/$SERVING_REPO/releases/latest" | \
    grep '"tag_name":' | \
    sed -E 's/.*"([^"]+)".*/\1/' | \
    sed 's/^knative-v//' | \
    sed 's/^v//')

EVENTING_VERSION=$(curl -s "https://api.github.com/repos/$EVENTING_REPO/releases/latest" | \
    grep '"tag_name":' | \
    sed -E 's/.*"([^"]+)".*/\1/' | \
    sed 's/^knative-v//' | \
    sed 's/^v//')

kubectl apply -f "https://github.com/knative/serving/releases/download/knative-v${SERVING_VERSION}/serving-crds.yaml"
kubectl apply -f "https://github.com/knative/serving/releases/download/knative-v${SERVING_VERSION}/serving-core.yaml"
kubectl apply -f "https://github.com/knative/net-kourier/releases/download/knative-v${KOURIER_VERSION}/kourier.yaml"
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'

kubectl apply -f "https://github.com/knative/eventing/releases/download/knative-v${EVENTING_VERSION}/eventing-crds.yaml"
kubectl apply -f "https://github.com/knative/eventing/releases/download/knative-v${EVENTING_VERSION}/eventing-core.yaml"

kubectl apply -f "https://github.com/knative/eventing/releases/download/knative-v${EVENTING_VERSION}/mt-channel-broker.yaml"

# Deploy Knative Operator
kubectl apply -f "https://github.com/knative/operator/releases/download/knative-v${OPERATOR_VERSION}/operator.yaml" --wait

