#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add helpyio/helpy https://scott.github.io/helpy-helm/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="helpy"
CHART="helpyio/helpy"
NAMESPACE="helpy"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/helpy/values.yml"
else
    # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/scott/helpy-helm/master/charts/helpy/values.yaml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
