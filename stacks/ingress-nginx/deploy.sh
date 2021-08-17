#!/bin/sh

set -e

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.48.1/deploy/static/provider/do/deploy.yaml
