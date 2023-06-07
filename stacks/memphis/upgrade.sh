#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add memphis https://k8s.memphis.dev/charts/
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="memphis"
CHART="memphis/memphis"
NAMESPACE="memphis"
CT=$(kubectl get secret --namespace "memphis" memphis-creds -o jsonpath="{.data.CONNECTION_TOKEN}" | base64 -d)
ROOT_PASSWORD=$(kubectl get secret --namespace "memphis" memphis-creds -o jsonpath="{.data.ROOT_PASSWORD}" | base64 -d)
PASSWORD=$(kubectl get secret --namespace "memphis" memphis-metadata -o jsonpath="{.data.password}" | base64 -d)
REPMGR_PASSWORD=$(kubectl get secret --namespace "memphis" memphis-metadata -o jsonpath="{.data.repmgr-password}" | base64 -d)
ADMIN_PASSWORD=$(kubectl get secret --namespace "memphis" memphis-metadata-coordinator -o jsonpath="{.data.admin-password}" | base64 -d)

if [ -z "${MP_KUBERNETES}" ]; then
    # use local version of values.yml
    ROOT_DIR=$(git rev-parse --show-toplevel)
    values="$ROOT_DIR/stacks/memphis/values.yml"
else
    # use github hosted master version of values.yml
    values="https://raw.githubusercontent.com/memphisdev/memphis-k8s/gh-pages/memphis/values.yaml"
fi

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$values" \
--set metadata.postgresql.password=$PASSWORD,\
metadata.postgresql.repmgrPassword=$REPMGR_PASSWORD,\
metadata.pgpool.adminPassword=$ADMIN_PASSWORD,\
connectionToken=$CT,\
rootPwd=$ROOT_PASSWORD
