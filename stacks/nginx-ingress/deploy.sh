#!/bin/sh

set -e

VERSION=nginx-0.26.1

# deploy
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/$VERSION/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/$VERSION/deploy/static/provider/cloud-generic.yaml

# ensure services are running
kubectl rollout status -w deployment/nginx-ingress-controller -n ingress-nginx
