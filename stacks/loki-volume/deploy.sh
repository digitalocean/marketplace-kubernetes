#!/bin/sh

set -e

################################################################################
# repo
################################################################################
# helm repo add loki-stack https://kmpartner.github.io/loki-grafana-volume
helm repo add loki-volume https://grafana.github.io/loki/charts

helm repo update

################################################################################
# chart
################################################################################
STACK="loki-volume"
CHART="loki-volume/loki-stack"
CHART_VERSION="0.40.1"
NAMESPACE="loki"

# if [ -z "${MP_KUBERNETES}" ]; then
#   # use local version of values.yml
#   ROOT_DIR=$(git rev-parse --show-toplevel)
#   values="$ROOT_DIR/stacks/loki-volume/values.yml"
# else
#   # use github hosted master version of values.yml
#   values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/loki-volume/values.yml"
# fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --install \
  --create-namespace \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  --set "loki.persistence.enabled=true" --set "loki.persistence.size=10Gi" --set "loki.persistence.storageClassName=do-block-storage" --set "grafana.enabled=true"



# #grab the password of admin user (admin) for grafana:
# kubectl get secret --namespace loki loki-volume-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# #port-forward loki-grfana pod on local port 4000
# kubeclt get pod -n loki
# kubectl port-forward <<loki-grafan pod name>> 4000:3000 -n loki 

# #open localhost:4000 in browser