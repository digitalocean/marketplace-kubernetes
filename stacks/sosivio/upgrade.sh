#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add sosivio https://helm.sosiv.io
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="sosivio"
CHART="sosivio/sosivio"
NAMESPACE="sosivio"

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/sosivio/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/sosivio/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--set expose=PortForward
