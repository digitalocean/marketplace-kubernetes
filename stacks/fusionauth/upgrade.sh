#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add fusionauth https://fusionauth.github.io/charts
helm repo update > /dev/null


################################################################################
# chart
################################################################################
STACK="fusionauth"
CHART="fusionauth/fusionauth"
NAMESPACE="fusionauth"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/fusionauth/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/fusionauth/values.yml"
fi

# Retrieve current password and set it again during upgrade.
DB_FUSIONAUTH_USER_PASSWORD=$(kubectl -n $NAMESPACE get secrets fusionauth-credentials -o jsonpath='{.data.password}' | base64 -D)

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
--set app.memory=3072M \
--set database.user=fusionauth \
--set database.password="$DB_FUSIONAUTH_USER_PASSWORD" \
--set database.host=db-postgresql.fusionauth.svc.cluster.local \
--set search.host=search-elasticsearch.fusionauth.svc.cluster.local \
