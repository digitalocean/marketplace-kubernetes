#!/bin/sh

set -e

kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml

# set kubectl namespace
kubectl config set-context --current --namespace=openfaas

# deploy openfaas
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/openfaas/yaml/openfaas.yaml

# ensure services are running
kubectl rollout status -n openfaas deployment/gateway
