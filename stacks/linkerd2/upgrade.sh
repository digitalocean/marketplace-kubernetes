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

# set kubectl namespace
kubectl config set-context --current --namespace=linkerd

# upgrade linkerd
$BINARY upgrade | kubectl apply --prune -l linkerd.io/control-plane-ns=linkerd -f -

$BINARY upgrade | kubectl apply --prune -l linkerd.io/control-plane-ns=linkerd \
  --prune-whitelist=rbac.authorization.k8s.io/v1/clusterrole \
  --prune-whitelist=rbac.authorization.k8s.io/v1/clusterrolebinding \
  --prune-whitelist=apiregistration.k8s.io/v1/apiservice -f -

# ensure services are running
kubectl get deployments -o custom-columns=NAME:.metadata.name | tail -n +2 | while read -r line
do
  if [ ! -z "$line" ]
  then 
    kubectl rollout status -w deployment/"$line"
  else
    break
  fi
done

# upgrade the viz extension
$BINARY viz install | kubectl apply -f -

# cleanup
rm -rf "$TMP_DIR"
