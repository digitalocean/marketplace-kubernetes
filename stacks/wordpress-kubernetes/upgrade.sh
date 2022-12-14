#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="wordpress-kubernetes"
CHART="bitnami/wordpress"
NAMESPACE="wordpress"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/wordpress-kubernetes/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/wordpress-kubernetes/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --set wordpressPassword=$(kubectl get secret --namespace "wordpress" wordpress-kubernetes -o jsonpath="{.data.wordpress-password}" | base64 --decode) \
  --set mariadb.auth.rootPassword=$(kubectl get secret --namespace "wordpress" wordpress-kubernetes-mariadb -o jsonpath="{.data.mariadb-root-password}" | base64 --decode) \
  --set mariadb.auth.password=$(kubectl get secret --namespace "wordpress" wordpress-kubernetes-mariadb -o jsonpath="{.data.mariadb-password}" | base64 --decode)
