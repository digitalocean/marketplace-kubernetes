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
CHART_VERSION="1.0.14"
NAMESPACE="fusionauth"

DB_POSTGRES_USER_PASSWORD=`LC_CTYPE=C LC_ALL=C tr -dc '[:alnum:]' < /dev/urandom | head -c 42`
DB_FUSIONAUTH_USER_PASSWORD=`LC_CTYPE=C LC_ALL=C tr -dc '[:alnum:]' < /dev/urandom | head -c 42`

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
helm install postgres-operator postgres-operator-charts/postgres-operator \
  --namespace "$NAMESPACE" \
  --create-namespace

# Creating secret for Postgres
kubectl create secret generic db-secret \
  --from-literal=postgres-password="$DB_POSTGRES_USER_PASSWORD" \
  -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

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
  env:
    - name: POSTGRES_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: postgres-password
EOF

helm install search-elasticsearch opensearch/opensearch \
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
  --set database.user="fusionauth" \
  --set database.password="$DB_FUSIONAUTH_USER_PASSWORD" \
  --set database.root.password="$DB_POSTGRES_USER_PASSWORD" \
  --set search.host=opensearch-cluster-master
