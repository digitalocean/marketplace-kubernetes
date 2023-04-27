#!/bin/sh

set -e

STACK="vmoperator"
NAMESPACE="default"

helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
