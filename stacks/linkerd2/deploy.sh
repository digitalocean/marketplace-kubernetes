#!/bin/sh

set -e

# cleanup
kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/src/linkerd2/yaml/linkerd2.yaml

# ensure services are running
kubectl get deployments -o custom-columns=NAME:.metadata.name | tail -n +2 | while read -r line
do
  kubectl rollout status -w deployment/"$line"
done
