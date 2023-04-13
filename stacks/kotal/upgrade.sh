#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add kotal https://kotalco.github.io/kotal-helm-chart
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="kotal"
CHART="kotal/kotal"
NAMESPACE="kotal"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/kotal/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/kotal/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
