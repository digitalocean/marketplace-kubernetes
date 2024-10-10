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
OLD_STACK="gp-lite-4-2"
OLD_CHART="gopaddle/gp-installer"
OLD_NAMESPACE="gp-lite-4-2"
CHART_VERSION="5"


if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/gopaddle-lite/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/gopaddle-lite/values.yml"
fi

kubectl delete all --all --namespace "$OLD_NAMESPACE" --ignore-not-found=true

helm upgrade "$OLD_STACK" "$OLD_CHART" \
  --namespace "$OLD_NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
