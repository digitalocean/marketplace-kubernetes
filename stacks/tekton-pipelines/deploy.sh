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
CHART_VERSION="0.29.0"
NAMESPACE="tekton-pipelines"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/tekton-pipelines/values.yml"
  # TODO: remove when https://github.com/cdfoundation/tekton-helm-chart/issues/19 gets fixed
  tekton_ns_manifest="$ROOT_DIR/stacks/tekton-pipelines/assets/manifests/tekton-ns.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/tekton-pipelines/values.yml"
  # TODO: remove when https://github.com/cdfoundation/tekton-helm-chart/issues/19 gets fixed
  tekton_ns_manifest="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/tekton-pipelines/assets/manifests/tekton-ns.yml"
fi

# The CDF Helm chart has the namespace hardcoded to "tekton-pipelines"
# TODO: remove when https://github.com/cdfoundation/tekton-helm-chart/issues/19 gets fixed
kubectl apply -f "$tekton_ns_manifest"

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
# --create-namespace
