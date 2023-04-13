#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add ls-k8s-webadc https://litespeedtech.github.io/helm-chart
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="ls-k8s-webadc"
CHART="ls-k8s-webadc/ls-k8s-webadc"
NAMESPACE="ls-k8s-webadc"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/ls-k8s-webadc/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/ls-k8s-webadc/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" --debug 
