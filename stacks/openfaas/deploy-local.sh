#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml

# set kubectl namespace
kubectl config set-context --current --namespace=openfaas

# deploy openfaas
kubectl apply -f "$ROOT_DIR"/stacks/openfaas/yaml/openfaas.yaml

# ensure services are running
kubectl rollout status -n openfaas deployment/gateway
