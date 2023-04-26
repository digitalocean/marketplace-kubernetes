#!/bin/sh

set -e

STACK="netdata"
NAMESPACE="netdata"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
