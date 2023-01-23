#!/bin/sh

# SPDX-FileCopyrightText: © 2019–2022 DigitalOcean
# SPDX-License-Identifier: Apache-2.0

set -e

################################################################################
# repo
################################################################################
helm repo add pachyderm https://helm.pachyderm.com
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="pachyderm"
CHART="pachyderm/pachyderm"
CHART_VERSION="2.4.4"
NAMESPACE="pachyderm"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/pachyderm/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/pachyderm/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" --debug
