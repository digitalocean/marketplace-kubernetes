#!/bin/sh

set -eu

STACK="rstream-operator"
NAMESPACE="rstream-system"

helm uninstall "$STACK" --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
