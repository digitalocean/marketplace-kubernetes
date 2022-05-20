#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="openebs-nfs-provisioner"
NAMESPACE="openebs-nfs-provisioner"
STORAGE_CLASS_MANIFEST="assets/manifests/sc-rwx.yaml"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"

kubectl delete -f "$STORAGE_CLASS_MANIFEST"
