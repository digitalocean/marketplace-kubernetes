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
CHART_VERSION="0.10.10"
NAMESPACE="fusionauth"

# Generate password for db user
DB_PASSWORD=`cat /dev/random | tr -dc '[:alnum:]' | head -c 42`

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/fusionauth/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/fusionauth/values.yml"
fi

# Add repos and update
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add fusionauth https://fusionauth.github.io/charts
helm repo update > /dev/null

# Install PostgresSQL and Elasticsearch
helm install db bitnami/postgresql --create-namespace "$NAMESPACE" --namespace "$NAMESPACE" --set auth.username=fusionauth --set auth.password="$DB_PASSWORD" --set auth.database=fusionauth
helm install search bitnami/elasticsearch --namespace "$NAMESPACE" -f elastic-search-values.yaml

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  --set database.host=db-postgresql.fusionauth.svc.cluster.local  \
  --set search.host=search-elasticsearch.fusionauth.svc.cluster.local  \
  --set database.user=fusionauth \
  --set database.password="$DB_PASSWORD"