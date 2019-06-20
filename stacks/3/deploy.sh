#!/bin/sh

set -e

# deploy prometheus-operator
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/3/yaml/aggregated-metrics-reader.yaml
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/3/yaml/auth-delegator.yaml
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/3/yaml/auth-reader.yaml
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/3/yaml/metrics-apiservice.yaml
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/3/yaml/metrics-server-deployment.yaml
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/3/yaml/metrics-server-service.yaml
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/3/yaml/resource-reader.yaml

# ensure services are running
kubectl rollout status deployment/metrics-server -n kube-system
