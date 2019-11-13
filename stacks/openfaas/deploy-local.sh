#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)

kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml

# generate a random password
PASSWORD=$(head -c 12 /dev/urandom | shasum| cut -d' ' -f1)

kubectl -n openfaas create secret generic basic-auth \
--from-literal=basic-auth-user=admin \
--from-literal=basic-auth-password="$PASSWORD"

# set kubectl namespace
kubectl config set-context --current --namespace=openfaas

# deploy openfaas
kubectl apply -f "$ROOT_DIR"/stacks/openfaas/yaml/openfaas.yaml

# ensure services are running
kubectl rollout status -w -n openfaas deployment/gateway
