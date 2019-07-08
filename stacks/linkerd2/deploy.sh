#!/bin/sh

set -e

# deploy linkerd yaml
linkerd install --ignore-cluster | kubectl apply -f -

# ensure services are running
kubectl -n linkerd rollout status deployment/linkerd-controller
kubectl -n linkerd rollout status deployment/linkerd-grafana
kubectl -n linkerd rollout status deployment/linkerd-identity
kubectl -n linkerd rollout status deployment/linkerd-prometheus
kubectl -n linkerd rollout status deployment/linkerd-sp-validator
kubectl -n linkerd rollout status deployment/linkerd-web
