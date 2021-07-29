#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add stable https://charts.helm.sh/stable
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="SAWO"
CHART="SAWO/SAWO"
NAMESPACE="SAWO"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/SAWO/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/SAWO/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
