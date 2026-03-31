#!/bin/sh
set -e

################################################################################
# DigitalOcean Marketplace Kubernetes — Defensia Agent (Uninstall)
################################################################################

STACK_NAME="defensia-agent"
NAMESPACE="defensia-system"

helm uninstall "$STACK_NAME" --namespace "$NAMESPACE"
kubectl delete namespace "$NAMESPACE" --ignore-not-found=true
