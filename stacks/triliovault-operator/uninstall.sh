#!/bin/sh

################################################################################
# Delete TVK license, manage and operator chart
################################################################################
STACK="triliovault-operator"
NAMESPACE="tvk"
ROOT_DIR=$(git rev-parse --show-toplevel)
TVM="$ROOT_DIR/stacks/$STACK/triliovault-manager.yaml"

echo "Make sure that there are no backups in inprogress state"

echo "Deleting TVK License ..."
kubectl delete license --all --namespace "$NAMESPACE"

echo ""
echo "Deleting TVK Manager ..."
kubectl delete -f "$TVM" --namespace "$NAMESPACE"

echo ""
echo "Deleting TVK Operator chart ..."
helm uninstall "$STACK" --namespace "$NAMESPACE"
