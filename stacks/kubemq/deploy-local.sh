#!/bin/sh

set -e

# deploy kubemq
kubectl apply -f https://get.kubemq.io/deploy?source=digital-ocean

# ensure services are running
kubectl rollout status statefulset/kubemq-cluster -n kubemq
