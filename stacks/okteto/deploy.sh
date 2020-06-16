#!/bin/sh

set -e

CHART_VERSION="0.5.1"
RELEASE="do"
NAMESPACE="okteto"

# create namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ${NAMESPACE}
  labels:
    certmanager.k8s.io/disable-validation: "true"
    app.kubernetes.io/name: "${NAMESPACE}"
EOF

if [ -z "${MP_KUBERNETES}" ]; then
  VALUES="values.yaml"
  CRDS="crds.yaml"
else
  VALUES="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/okteto/values.yaml"
  CRDS="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/okteto/crds.yaml"
fi

# deploy crds
kubectl apply -f $CRDS --namespace $NAMESPACE

# generate a random admin token
ADMIN_TOKEN=$(head -c 12 /dev/urandom | shasum| cut -d' ' -f1)

# install okteto
helm repo add okteto https://charts.okteto.com
helm repo update

helm upgrade "$RELEASE" "okteto/okteto-enterprise"  \
  --install \
  --values "$VALUES" \
  --namespace "$NAMESPACE" \
  --set adminToken="$ADMIN_TOKEN" \
  --version "$CHART_VERSION"

# ensure services are running
kubectl rollout status -w deployment/do-cert-manager --namespace "$NAMESPACE"
kubectl rollout status -w deployment/do-cert-manager-cainjector --namespace "$NAMESPACE"
kubectl rollout status -w deployment/do-nginx-ingress-controller --namespace "$NAMESPACE"
kubectl rollout status -w deployment/do-nginx-ingress-default-backend --namespace "$NAMESPACE"
kubectl rollout status -w deployment/do-okteto-enterprise-frontend --namespace "$NAMESPACE"
kubectl rollout status -w deployment/do-cert-manager-webhook --namespace "$NAMESPACE"
kubectl rollout status -w deployment/do-okteto-enterprise-api --namespace "$NAMESPACE"
kubectl rollout status -w deployment/do-okteto-enterprise-mutation-webhook --namespace "$NAMESPACE"