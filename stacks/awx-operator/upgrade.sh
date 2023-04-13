#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add awx-operator https://ansible.github.io/awx-operator/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="awx-operator"
CHART="awx-operator"
NAMESPACE="awx"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/awx-operator/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/awx-operator/values.yml"
fi

helm upgrade "$STACK" "$STACK/$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
