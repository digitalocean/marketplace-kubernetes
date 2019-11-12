#!/bin/sh

set -e

VERSION=nginx-0.26.1

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/$VERSION/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/$VERSION/deploy/static/provider/cloud-generic.yaml
