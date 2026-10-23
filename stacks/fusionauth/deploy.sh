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

# Add repos and update
helm repo add fusionauth https://fusionauth.github.io/charts
helm repo add postgres-operator-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator
helm repo add opensearch https://opensearch-project.github.io/helm-charts/
helm repo update > /dev/null

# Installing Postgres Operator
helm upgrade --install postgres-operator postgres-operator-charts/postgres-operator \
  --namespace "$NAMESPACE" \
  --create-namespace

# Creating PostgresCluster (using Zalando CRD)
cat <<EOF | kubectl apply -f -
apiVersion: acid.zalan.do/v1
kind: postgresql
metadata:
  name: db-postgresql
  namespace: $NAMESPACE
spec:
  teamId: "acid"
  volume:
    size: 5Gi
  numberOfInstances: 1
  users:
    fusionauth:
      - superuser
      - createdb
  databases:
    fusionauth: fusionauth
  postgresql:
    version: "17"
EOF

ATTEMPTS=0
until kubectl get --namespace "$NAMESPACE" \
  secret/fusionauth.db-postgresql.credentials.postgresql.acid.zalan.do \
  secret/postgres.db-postgresql.credentials.postgresql.acid.zalan.do >/dev/null 2>&1; do
  ATTEMPTS=$((ATTEMPTS + 1))
  if [ "$ATTEMPTS" -ge 150 ]; then
    echo "PostgreSQL credential Secrets were not created within 5 minutes" >&2
    exit 1
  fi
  sleep 2
done

helm upgrade --install search-elasticsearch opensearch/opensearch \
  --namespace "$NAMESPACE" \
  --set singleNode=true \
  --set persistence.enabled=false \
  --set config."opensearch\.yml"."plugins\.security\.disabled"=true

# 

# Installing FusionAuth
helm upgrade "$STACK" "$CHART" \
  --install \
  --atomic \
  --timeout 15m0s \
  --namespace "$NAMESPACE" \
  --values "$VALUES" \
  --version "$CHART_VERSION" \
  --set database.dbUser.username="fusionauth" \
  --set search.host=opensearch-cluster-master
