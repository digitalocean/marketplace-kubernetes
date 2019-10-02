#!/bin/sh

set -e

# set kubectl namespace
kubectl config set-context --current --namespace=linkerd

# deploy linkerd yaml
linkerd install --ignore-cluster | kubectl apply -f -

# ensure services are running
kubectl get deployments -o custom-columns=NAME:.metadata.name | tail -n +2 | while read -r line
do
  kubectl rollout status deployment/"$line"
done
