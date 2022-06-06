#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add --force-update cdf https://cdfoundation.github.io/tekton-helm-chart
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="tekton-pipeline"
CHART="cdf/tekton-pipeline"
NAMESPACE="tekton-pipelines"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/tekton-pipelines/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/tekton-pipelines/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
    --namespace "$NAMESPACE" \
    --values "$values"
