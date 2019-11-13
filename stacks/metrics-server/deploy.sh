#!/bin/sh

set -e

# set kubectl namespace
kubectl config set-context --current --namespace=kube-system

# deploy metrics-server
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/metrics-server/yaml/metrics-server.yaml

# ensure services are running
kubectl rollout status -w deployment/metrics-server
