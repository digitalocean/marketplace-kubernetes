#!/bin/sh

set -e

#set variables
ROOT_DIR=$(git rev-parse --show-toplevel)
LINKERD2_VERSION=${LINKERD2_VERSION:-stable-2.3.2}

#check OS type
if [ "$(uname -s)" = "Darwin" ]; then
  OS=darwin
else
  OS=linux
fi

#download linkerd
filename="linkerd2-cli-${LINKERD2_VERSION}-${OS}"
url="https://github.com/linkerd/linkerd2/releases/download/${LINKERD2_VERSION}/${filename}"
curl -LO "${url}"
chmod +x ${filename}

# deploy linkerd
./${filename} install | kubectl apply -f -

# ensure services are running
kubectl rollout status deployment/linkerd-web
kubectl rollout status deployment/linkerd-grafana
kubectl rollout status deployment/linkerd-prometheus

