#!/bin/sh

set -e

helm uninstall -n prometheus-operator prometheus-operator || echo -n 'prometheus-operator not installed'

kubectl delete ns prometheus-operator --ignore-not-found

################################################################################
# repo
################################################################################
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo update

################################################################################
# chart
################################################################################
STACK="prometheus-operator"
CHART="stable/prometheus-operator"
CHART_VERSION="9.3.0"
NAMESPACE="prometheus-operator"

# if [ -z "${MP_KUBERNETES}" ]; then
#   # use local version of values.yml
#   ROOT_DIR=$(git rev-parse --show-toplevel)
#   values="$ROOT_DIR/stacks/prometheus-operator/values.yml"
# else
#   # use github hosted master version of values.yml
#   values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/prometheus-operator/values.yml"
# fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --install \
  --create-namespace \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  --values "values.yaml"  \


# check if metrics-server is already installed
CHECK=$(kubectl get svc metrics-server -n kube-system --ignore-not-found)
if [ "$CHECK" = "" ]
then
  echo "metrics-server not found"
else
  echo "metrics-server found, exiting"
  exit 0
fi

################################################################################
# repo
################################################################################
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

################################################################################
# chart
################################################################################
STACK="metrics-server"
CHART="bitnami/metrics-server"
CHART_VERSION="4.3.0"
NAMESPACE="kube-system"

# if [ -z "${MP_KUBERNETES}" ]; then
#   # use local version of values.yml
#   ROOT_DIR=$(git rev-parse --show-toplevel)
#   values="$ROOT_DIR/stacks/metrics-server/values.yml"
# else
#   # use github hosted master version of values.yml
#   values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/metrics-server/values.yml"
# fi

helm upgrade --install "$STACK" "$CHART" --atomic --namespace "$NAMESPACE" --version "$CHART_VERSION" -f metrics-server-values.yaml





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





# # Install the CLI
curl -sL https://run.linkerd.io/install | sh

export PATH=$PATH:$HOME/.linkerd2/bin

# # verify the CLI
# # linkerd version

# # Validate your Kubernetes cluster
# # linkerd check --pre

# # Install Linkerd onto the cluster
linkerd install | kubectl apply -f -


# #add distributed tracing with linkerd

# cat >> config.yaml << EOF
# tracing:
#   enabled: true
#   collector:
#     resources:
#       cpu:
#         limit: 100m
#         request: 1m
#       memory:
#         limit: 100Mi
#         request: 1Mi
# EOF

# linkerd upgrade --addon-config config.yaml | kubectl apply -f -

# rm -rf config.yaml



# ---------

# prometheus-operator
# grafana login ID: admin, password: prom-operator


# loki
# #grab the password of admin user (admin) for grafana:
# kubectl get secret --namespace loki loki-volume-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# #port-forward loki-grfana pod on local port 4000
# kubeclt get pod -n loki
# kubectl port-forward <<loki-grafan pod name>> 4000:3000 -n loki 

# #open localhost:4000 in browser


# linkerd
# # check linkerd pod running
# kubectl get pod -n linkerd

# # expose UI
# kubectl -n linkerd port-forward linkerd-web-pod-name 8084:8084

# # inject linkerd to deployment in loki namsespace and analyze in browser localhost:8084
# kubectl -n loki get deploy -o yaml | linkerd inject - | kubectl apply -f -

# # uninject linkerd 
# kubectl -n loki get deploy -o yaml | linkerd uninject - | kubectl apply -f -

# #uninstall linderd    
# linkerd install --ignore-cluster | kubectl delete -f -