#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add gopaddle https://gopaddle-io.github.io/gopaddle-lite/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="gopaddle-lite"
CHART="gopaddle/gopaddle-lite"
NAMESPACE="gp-lite-4-2"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/gopaddle-lite/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/gopaddle-lite/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
