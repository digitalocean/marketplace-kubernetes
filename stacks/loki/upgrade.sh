#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="loki"
CHART="grafana/loki-stack"
NAMESPACE="monitoring"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/loki/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/loki/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
