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

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/openebs-nfs-provisioner/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/openebs-nfs-provisioner/values.yml"
fi

helm upgrade "$STACK" --namespace "$NAMESPACE" \
  "$CHART" \
  --set nfs-provisioner.enabled=true \
  --set lvm-localpv.crds.lvmLocalPv.enabled=false \
  --set zfs-localpv.crds.zfsLocalPv.enabled=false \
  --set mayastor.agents.core.rebuild.partial.enabled=false \
  --set openebs-crds.csi.volumeSnapshots.enabled=false \
  --timeout 20m0s \
  --version "$CHART_VERSION"
