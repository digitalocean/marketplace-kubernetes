#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add link-society-incubator https://charts.link-society.com/incubator
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="kapp-controller"
CHART="link-society-incubator/kapp-controller"
NAMESPACE="kapp-controller"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/kapp-controller/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/kapp-controller/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
