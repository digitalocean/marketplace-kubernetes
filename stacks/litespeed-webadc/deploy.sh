#!/bin/sh

#set -x

################################################################################
# repo
################################################################################
helm repo add ls-k8s-webadc https://litespeedtech.github.io/helm-chart
helm repo update > /dev/null

################################################################################
# chart
################################################################################
STACK="ls-k8s-webadc"
CHART="ls-k8s-webadc/ls-k8s-webadc"
CHART_VERSION="0.1.24"
NAMESPACE="ls-k8s-webadc"

kubectl get secret ls-k8s-webadc -n ls-k8s-webadc > /dev/null 2>&1
if [ "$?" -ne "0" ]; then
  kubectl create namespace $NAMESPACE > /dev/null 2>&1
  echo "Creating trial license.  If you have a paid for license, you should update the secret using the commands:" 
  echo "   kubectl delete secret -n $NAMESPACE $STACK"
  echo "   kubectl create secret generic -n $NAMESPACE $STACK --from-file=license=./license.key --from-file=serial=./serial.no"
  curl http://license.litespeedtech.com/reseller/trial.key > ./trial.key 2>/dev/null
  if [ "$?" -ne "0" ]; then
    echo "Error getting license information.  Contact Litespeed tech support"
    exit 1
  fi
  kubectl create secret generic -n $NAMESPACE $STACK --from-file=trial=./trial.key
  if [ "$?" -ne "0" ]; then
    echo "Error creating secret from trial key.  Fix error above and try again"
    exit 1
  fi
  rm trial.key
fi

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/litespeed-webadc/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/litespeed-webadc/values.yml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
