#!/bin/sh

set -e

################################################################################
# chart
################################################################################
STACK="openebs-nfs-provisioner"
NAMESPACE="openebs-nfs-provisioner"


helm uninstall "$STACK" \
  --namespace "$NAMESPACE"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of sc-rwx.yaml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  STORAGE_CLASS_MANIFEST="$ROOT_DIR/stacks/openebs-nfs-provisioner/assets/manifests/sc-nfs-rwx.yaml"
else
  # use github hosted master version of sc-rwx.yaml
  STORAGE_CLASS_MANIFEST="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/openebs-nfs-provisioner/assets/manifests/sc-nfs-rwx.yaml"
fi

kubectl delete -f "$STORAGE_CLASS_MANIFEST"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"