#!/bin/sh

set -e

echo "Deploying Nginx Ingress"

VERSION="nginx-0.25.1"

NAMESPACE=ingress-nginx

kubectl config set-context --current --namespace=$NAMESPACE

# install
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/"${VERSION}"/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/"${VERSION}"/deploy/static/provider/cloud-generic.yaml

# validate
kubectl get deployments -o custom-columns=NAME:.metadata.name | tail -n +2 | while read -r line
do
  kubectl rollout status deployment/"$line"
done
