#!/bin/sh

set -e

ROOT_DIR=$(git rev-parse --show-toplevel)
LINKERD2_VERSION="stable-2.5.0"

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
kubectl get deployments -o custom-columns=NAME:.metadata.name | tail -n +2 | while read -r line
do
  kubectl rollout status deployment/"$line"
done
