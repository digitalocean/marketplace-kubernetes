#!/bin/sh

set -e

LINKERD2_VERSION="stable-2.12.4"
TMP_DIR=$(mktemp -d)

# determine OS
if [ "$(uname -s)" = "Darwin" ]; then
  OS=darwin
else
  OS=linux-amd64
fi

FILENAME="linkerd2-cli-$LINKERD2_VERSION-$OS"
URL="https://github.com/linkerd/linkerd2/releases/download/$LINKERD2_VERSION/$FILENAME"
BINARY="$TMP_DIR/$FILENAME"

# download linkerd
wget -q $URL -O "$BINARY" && chmod +x "$BINARY"


# uninstall the viz extension
$BINARY viz uninstall | kubectl delete -f -

# uninstall linkerd
$BINARY uninstall | kubectl delete -f -

# cleanup
rm -rf "$TMP_DIR"
kubectl delete --ignore-not-found=true namespace "$NAMESPACE"
