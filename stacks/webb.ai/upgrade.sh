#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add webb.ai https://webb-ai.github.io/helm-charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="webbai-agent"
CHART="webb.ai/webbai-agent"
NAMESPACE="webbai"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/webb.ai/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/webb.ai/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
