#!/bin/sh

set -e

# set kubectl namespace
kubectl config set-context --current --namespace=linkerd

# deploy linkerd yaml
linkerd install --ignore-cluster | kubectl apply -f -

# ensure services are running
kubectl rollout status deployment/linkerd-controller
kubectl rollout status deployment/linkerd-grafana
kubectl rollout status deployment/linkerd-identity
kubectl rollout status deployment/linkerd-prometheus
kubectl rollout status deployment/linkerd-proxy-injector
kubectl rollout status deployment/linkerd-sp-validator
kubectl rollout status deployment/linkerd-tap
kubectl rollout status deployment/linkerd-web
