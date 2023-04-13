#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add paralus https://paralus.github.io/helm-charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="paralus"
CHART="paralus/ztka"
NAMESPACE="paralus"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/paralus/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/paralus/helm-charts/main/examples/values.dev-generic.yaml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \