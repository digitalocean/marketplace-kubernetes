#!/bin/sh

set -e

# set kubectl namespace
kubectl config set-context --current --namespace=rstudio

# deploy netdata
kubectl apply -f rstudio.yaml

