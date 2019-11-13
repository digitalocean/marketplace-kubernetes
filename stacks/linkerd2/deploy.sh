#!/bin/sh

set -e

LINKERD2_VERSION="stable-2.6.0"
TMP_DIR=$(mktemp -d)

# determine OS
if [ "$(uname -s)" = "Darwin" ]; then
  OS=darwin
else
  OS=linux
fi

FILENAME="linkerd2-cli-$LINKERD2_VERSION-$OS"
URL="https://github.com/linkerd/linkerd2/releases/download/$LINKERD2_VERSION/$FILENAME"
BINARY="$TMP_DIR/$FILENAME"

# download linkerd
wget -q $URL -O "$BINARY" && chmod +x "$BINARY"

# set kubectl namespace
kubectl config set-context --current --namespace=linkerd

# deploy linkerd
$BINARY install --ignore-cluster | kubectl apply -f -

# ensure services are running
kubectl get deployments -o custom-columns=NAME:.metadata.name | tail -n +2 | while read -r line
do
  kubectl rollout status -w deployment/"$line"
done

# cleanup
rm -rf "$TMP_DIR"
