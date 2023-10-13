#!/bin/sh

set -e

################################################################################
# Delete TVK license, manage and operator chart
################################################################################
STACK="triliovault-operator"
NAMESPACE="tvk"
#ROOT_DIR=$(git rev-parse --show-toplevel)

echo "Make sure that there are no backups in inprogress state"

echo "Deleting TVK License ..."
kubectl delete license --all --namespace "$NAMESPACE"

echo ""
echo "Looking for TVM custom resource name"
TVM_CR=$(kubectl get tvm --no-headers=true --namespace "$NAMESPACE" 2>/dev/null | awk '{print $1}')
TVM_NAME=$(kubectl get tvm "$TVM_CR" --namespace "$NAMESPACE" -o jsonpath='{.metadata.name}')

echo "Deleting TVK Manager ..."
kubectl delete tvm "$TVM_NAME" --namespace "$NAMESPACE"

echo ""
echo "Deleting TVK Operator chart ..."
helm uninstall "$STACK" --namespace "$NAMESPACE"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
