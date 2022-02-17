#!/bin/sh

set -e

# create namespace
kubectl create namespace shiny

# deploy shiny
if [ -z "${MP_KUBERNETES}" ]; then
  ROOT_DIR=$(git rev-parse --show-toplevel)
  kubectl apply -n shiny -f "$ROOT_DIR"/stacks/shiny/shiny.yaml
else
  kubectl apply -n shiny -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/shiny/shiny.yaml
fi

