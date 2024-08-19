#!/bin/sh

set -e

################################################################################
# repo
################################################################################


################################################################################
# chart
################################################################################
STACK="fusionauth"
CHART="fusionauth/fusionauth"
CHART_VERSION="1.0.8"
NAMESPACE="fusionauth"

DB_POSTGRES_USER_PASSWORD=`LC_CTYPE=C LC_ALL=C tr -dc '[:alnum:]' < /dev/urandom | head -c 42`
DB_FUSIONAUTH_USER_PASSWORD=`LC_CTYPE=C LC_ALL=C tr -dc '[:alnum:]' < /dev/urandom | head -c 42`

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  VALUES="$ROOT_DIR/stacks/fusionauth/values.yml"
  SEARCH_VALUES="$ROOT_DIR/stacks/fusionauth/search-values.yaml"
else
  # use github hosted master version of values.yml
  VALUES="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/fusionauth/values.yml"
  SEARCH_VALUES="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/fusionauth/search-values.yaml"
fi

# Add repos and update
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add fusionauth https://fusionauth.github.io/charts
helm repo update > /dev/null
# Install PostgresSQL and Elasticsearch
helm install --atomic db bitnami/postgresql --create-namespace --namespace "$NAMESPACE" --set auth.enablePostgresUser=true --set auth.postgresPassword="$DB_POSTGRES_USER_PASSWORD" --set image.tag=14.9.0-debian-11-r2
helm install --atomic search bitnami/elasticsearch --namespace "$NAMESPACE" -f "$SEARCH_VALUES"

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$VALUES" \
  --version "$CHART_VERSION" \
  --set database.password="$DB_FUSIONAUTH_USER_PASSWORD" \
  --set database.root.password="$DB_POSTGRES_USER_PASSWORD"
