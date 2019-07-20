#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)
LINKERD2_VERSION="stable-2.4.0"

# check OS type
if [ "$(uname -s)" = "Darwin" ]; then
  OS=darwin
else
  OS=linux
fi

FILENAME="linkerd2-cli-${LINKERD2_VERSION}-${OS}"
URL="https://github.com/linkerd/linkerd2/releases/download/${LINKERD2_VERSION}/${FILENAME}"
BINARY="$ROOT_DIR"/stacks/linkerd2/bin/"${FILENAME}"

if [ ! -f "${BINARY}" ]; then
  # download linkerd
  mkdir -p "$ROOT_DIR"/stacks/linkerd2/bin
  wget ${URL} -O ${BINARY} && chmod +x ${BINARY}
fi

# set kubectl namespace
kubectl config set-context --current --namespace=linkerd

# deploy linkerd
${BINARY} install --ignore-cluster | kubectl apply -f -

# ensure services are running
kubectl rollout status deployment/linkerd-controller
kubectl rollout status deployment/linkerd-grafana
kubectl rollout status deployment/linkerd-identity
kubectl rollout status deployment/linkerd-prometheus
kubectl rollout status deployment/linkerd-proxy-injector
kubectl rollout status deployment/linkerd-sp-validator
kubectl rollout status deployment/linkerd-tap
kubectl rollout status deployment/linkerd-web
