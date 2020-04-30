#!/bin/sh

set -e

LINKERD2_VERSION="stable-2.7.1"
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

# recreate yaml directory
rm -rf stacks/linkerd2/yaml
mkdir -p stacks/linkerd2/yaml

# deploy linkerd
$BINARY install --ignore-cluster > src/linkerd2/"$LINKERD2_VERSION"/linkerd2.yaml
cp src/linkerd2/"$LINKERD2_VERSION"/linkerd2.yaml stacks/linkerd2/yaml/linkerd2.yaml

# cleanup
rm -rf "$TMP_DIR"