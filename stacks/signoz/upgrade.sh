#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add charts https://github.com/signoz/charts.git
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="signoz"
CHART="charts/signoz"
NAMESPACE="signoz"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/signoz/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/signoz/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
