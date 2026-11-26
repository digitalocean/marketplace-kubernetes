#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add valeria-one https://valeriaone.github.io/helm-charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="valeria-one"
CHART="valeria-one/valeria-one"
CHART_VERSION="1.0.0"
NAMESPACE="valeria-one"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/valeria-one/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/valeria-one/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
--version "$CHART_VERSION"
