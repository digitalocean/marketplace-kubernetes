#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add 8xff https://8xff.github.io/helm/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="atm0s-media-stack"
CHART="8xff/atm0s-media-stack"
NAMESPACE="atm0s-media"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/atm0s-media-stack/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/atm0s-media-stack/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
