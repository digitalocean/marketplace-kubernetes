#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add stable https://charts.helm.sh/stable
helm repo add postgres-operator-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator
helm repo add opensearch https://opensearch-project.github.io/helm-charts/
helm repo add fusionauth https://fusionauth.github.io/charts
helm repo update > /dev/null


################################################################################
# chart
################################################################################
STACK="fusionauth"
CHART="fusionauth/fusionauth"
CHART_VERSION="1.69.3"
NAMESPACE="fusionauth"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  VALUES="$ROOT_DIR/stacks/fusionauth/values.yml"
else
  # use github hosted master version of values.yml
  VALUES="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/fusionauth/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$VALUES" \
--version "$CHART_VERSION" \
--set database.dbUser.username="fusionauth" \
--set search.host=opensearch-cluster-master
