#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add --force-update openebs https://openebs.github.io/openebs
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="openebs"
CHART="openebs/openebs"
NAMESPACE="openebs-nfs-provisioner"
CHART_VERSION="4.0.1"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/openebs-nfs-provisioner/values.yml"
  # use local version of sc-rwx.yaml
  STORAGE_CLASS_MANIFEST="$ROOT_DIR/stacks/openebs-nfs-provisioner/assets/manifests/sc-nfs-rwx.yaml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/openebs-nfs-provisioner/values.yml"
  # use github hosted master version of sc-rwx.yaml
  STORAGE_CLASS_MANIFEST="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/openebs-nfs-provisioner/assets/manifests/sc-nfs-rwx.yaml"
fi

helm upgrade $STACK --namespace $NAMESPACE \
  $CHART \
  --create-namespace \
  --install \
  --set nfs-provisioner.enabled=true \
  --set lvm-localpv.crds.lvmLocalPv.enabled=false \
  --set zfs-localpv.crds.zfsLocalPv.enabled=false \
  --set mayastor.agents.core.rebuild.partial.enabled=false \
  --set openebs-crds.csi.volumeSnapshots.enabled=false \
  --timeout 20m0s \
  --values "$values" \
  --version "$CHART_VERSION"

kubectl apply -f "$STORAGE_CLASS_MANIFEST"
