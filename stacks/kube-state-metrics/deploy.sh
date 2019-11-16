#!/bin/sh

set -e

# set kubectl namespace
kubectl config set-context --current --namespace=kube-system

# deploy kube-state-metrics
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/kube-state-metrics/yaml/kube-state-metrics.yaml

# ensure services are running
kubectl rollout status -w deployment/kube-state-metrics
