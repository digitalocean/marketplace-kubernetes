#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add easegress https://megaease.github.io/easegress-helm-charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="easegress"
CHART="easegress/easegress"
NAMESPACE="easegress"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/easegress/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/easegress/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
