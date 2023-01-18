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
  VALUES="$ROOT_DIR/stacks/fusionauth/values.yml"
else
  # use github hosted master version of values.yml
  VALUES="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/fusionauth/values.yml"
fi

# Retrieve current passwords and set them again during upgrade.
DB_FUSIONAUTH_USER_PASSWORD=$(kubectl -n $NAMESPACE get secrets fusionauth-credentials -o jsonpath='{.data.password}' | base64 -d)
DB_POSTGRES_USER_PASSWORD=$(kubectl -n $NAMESPACE get secrets fusionauth-credentials -o jsonpath='{.data.rootpassword}' | base64 -d)

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$VALUES" \
--set database.password="$DB_FUSIONAUTH_USER_PASSWORD" \
--set database.root.password="$DB_POSTGRES_USER_PASSWORD"
