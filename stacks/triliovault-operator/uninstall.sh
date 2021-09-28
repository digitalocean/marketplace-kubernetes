#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="triliovault-operator"
NAMESPACE="tvk"
ROOT_DIR=$(git rev-parse --show-toplevel)
TVM="$ROOT_DIR/stacks/$STACK/triliovault-manager.yaml"

echo "Make sure that there are no backups in inprogress state"

kubectl delete -f "$TVM" --namespace "$NAMESPACE"

helm uninstall "$STACK" --namespace "$NAMESPACE"
