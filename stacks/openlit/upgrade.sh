#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add openlit https://openlit.github.io/helm/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="openlit"
CHART="openlit/openlit"
NAMESPACE="openlit"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/openlit/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/openlit/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
