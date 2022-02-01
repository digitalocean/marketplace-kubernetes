#!/bin/sh

set -e

# set kubectl namespace
kubectl create namespace rstudio
kubectl config set-context --current --namespace=rstudio

# deploy rstudio
kubectl apply -f rstudio.yaml
