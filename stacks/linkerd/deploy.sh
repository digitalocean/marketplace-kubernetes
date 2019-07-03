#!/bin/sh

set -e

# deploy linkerd yaml
linkerd install | kubectl apply -f -

# ensure services are running
kubectl rollout status deployment/linkerd
