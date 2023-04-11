#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="tekton-pipeline"
NAMESPACE="tekton-pipelines"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
