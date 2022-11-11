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
export LC_CTYPE=C
#DB_PASSWORD=`cat /dev/random | tr -dc '[:alnum:]' | head -c 42`
DB_PASSWORD=password123

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
helm install db bitnami/postgresql --create-namespace --namespace "$NAMESPACE" --set auth.enablePostgresUser=true --set auth.postgresPassword=password
helm install search bitnami/elasticsearch --namespace "$NAMESPACE" -f search-values.yaml

#read -t 20 -p "I am going to wait for 20 seconds only ..."

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
  --set database.password="$DB_PASSWORD" \
  --set database.root.user=postgres \
  --set database.root.password=password
