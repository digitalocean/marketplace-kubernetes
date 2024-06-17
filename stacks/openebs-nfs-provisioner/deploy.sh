#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add openebs-nfs https://openebs-archive.github.io/dynamic-nfs-provisioner
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="openebs-nfs-provisioner"
CHART="openebs-nfs/nfs-provisioner"
CHART_VERSION="0.11.0"
NAMESPACE="openebs-nfs-provisioner"

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

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"

kubectl apply -f "$STORAGE_CLASS_MANIFEST"
