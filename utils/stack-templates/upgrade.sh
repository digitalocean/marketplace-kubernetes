#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add {{HELM_REPO_NAME}} {{HELM_REPO_URL}}
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="{{STACK_NAME}}"
CHART="{{CHART_NAME}}"
NAMESPACE="{{NAMESPACE}}"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/{{STACK_NAME}}/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/{{STACK_NAME}}/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
