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
CHART_VERSION="1.2.0"
NAMESPACE="helpy"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/helpy/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/scott/helpy-helm/master/charts/helpy/values.yaml"
fi

# NOTE: I could not get this to deploy with helm upgrade

helm upgrade "$STACK" "$CHART" \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"

# helm install "$STACK" "$CHART" -n "$NAMESPACE" --values "$values"