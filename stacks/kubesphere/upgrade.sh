#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo  add main https://charts.kubesphere.io/main
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="kubesphere"
CHART="main/ks-installer"
NAMESPACE="kubesphere-system"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/kubesphere/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/kubesphere/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
