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


DB_POSTGRES_USER_PASSWORD=`cat /dev/urandom | tr -dc '[:alnum:]' | head -c 42`
DB_FUSIONAUTH_USER_PASSWORD=`cat /dev/urandom | tr -dc '[:alnum:]' | head -c 42`

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

#echo "Password $DB_PASSWORD"
# Install PostgresSQL and Elasticsearch
helm install db bitnami/postgresql --create-namespace --namespace "$NAMESPACE" --set auth.enablePostgresUser=true --set auth.postgresPassword="$DB_POSTGRES_USER_PASSWORD" --set image.tag=14.6.0-debian-11-r11
helm install search bitnami/elasticsearch --namespace "$NAMESPACE" -f search-values.yaml


helm upgrade "$STACK" "$CHART" \
  --atomic \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  --set app.memory=3072M \
  --set database.host=db-postgresql.fusionauth.svc.cluster.local  \
  --set search.host=search-elasticsearch.fusionauth.svc.cluster.local  \
  --set database.user=fusionauth \
  --set database.password="$DB_FUSIONAUTH_USER_PASSWORD" \
  --set database.root.user=postgres \
  --set database.root.password="$DB_POSTGRES_USER_PASSWORD"
