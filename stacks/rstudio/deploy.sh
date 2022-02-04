#!/bin/sh

set -e

# create namespace
kubectl create namespace rstudio

# deploy rstudio
if [ -z "${MP_KUBERNETES}" ]; then
  ROOT_DIR=$(git rev-parse --show-toplevel)
  kubectl apply -n rstudio -f "$ROOT_DIR"/stacks/rstudio/rstudio.yaml
else
  kubectl apply -n rstudio -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/rstudio/rstudio.yaml
fi

