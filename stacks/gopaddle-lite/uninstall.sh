#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="gopaddle"
NAMESPACE="gopaddle"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"

kubectl delete ns "$NAMESPACE" --ignore-not-found=true
kubectl delete clusterrole gopaddle --ignore-not-found=true
kubectl delete clusterrolebinding gopaddle --ignore-not-found=true
