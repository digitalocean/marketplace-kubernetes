#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add memphis https://k8s.memphis.dev/charts/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="memphis"
CHART="memphis/memphis"
NAMESPACE="memphis"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/memphis/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/memphis/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
