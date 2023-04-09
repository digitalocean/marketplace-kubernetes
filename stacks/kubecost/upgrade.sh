#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add cost-analyzer https://kubecost.github.io/cost-analyzer/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="kubecost"
CHART="cost-analyzer/cost-analyzer"
NAMESPACE="kubecost"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/kubecost/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/kubecost/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
