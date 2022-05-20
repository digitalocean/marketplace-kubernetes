#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add openebs-nfs https://openebs.github.io/dynamic-nfs-provisioner
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="openebs-nfs-provisioner"
CHART="openebs-nfs/nfs-provisioner"
CHART_VERSION="0.9.0"
NAMESPACE="openebs-nfs-provisioner"
STORAGE_CLASS_MANIFEST="assets/manifests/sc-rwx.yaml"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/openebs-nfs-provisioner/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/openebs-nfs/values.yml"
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
