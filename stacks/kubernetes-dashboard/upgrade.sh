#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="kubernetes-dashboard"
CHART="kubernetes-dashboard/kubernetes-dashboard"
NAMESPACE="kubernetes-dashboard"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/kubernetes-dashboard/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/kubernetes-dashboard/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
