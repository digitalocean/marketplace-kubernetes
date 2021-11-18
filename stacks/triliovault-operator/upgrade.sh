#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add triliovault-operator http://charts.k8strilio.net/trilio-stable/k8s-triliovault-operator
helm repo update > /dev/null

################################################################################
# TVK Operator chart upgrade
################################################################################
STACK="triliovault-operator"
CHART="triliovault-operator/k8s-triliovault-operator"
CHART_VERSION="2.6.0"
NAMESPACE="tvk"
#HOME=$ROOT_DIR

# Upgrade triliovault operator
echo "Upgrading Triliovault operator..."

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/triliovault-operator/values.yml"
  TVM="$ROOT_DIR/stacks/$STACK/triliovault-manager.yaml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/triliovault-operator/values.yml"
  TVM="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/triliovault-operator/triliovault-manager.yaml"
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"

until (kubectl get pods --namespace "$NAMESPACE" -l "release=triliovault-operator" 2>/dev/null | grep Running); do sleep 3; done

################################################################################
# TVK Manager Upgrade
################################################################################

install_tvm () {
  # Upgrade triliovault manager
  echo "Upgrading Triliovault manager..."

  kubectl apply -f "$TVM" --namespace "$NAMESPACE"
  retcode=$?

  if [ "$retcode" -ne 0 ];then
    echo "Some error occurred during triliovault-manager installation using label definition, please contanct Trilio support"
    return 1
  fi

  until (kubectl get pods --namespace "$NAMESPACE" -l "triliovault.trilio.io/owner=triliovault-manager" 2>/dev/null | grep Running); do sleep 3; done

  until (kubectl get pods --namespace "$NAMESPACE" -l app=k8s-triliovault-control-plane 2>/dev/null | grep Running); do sleep 3; done

  until (kubectl get pods --namespace "$NAMESPACE" -l app=k8s-triliovault-admission-webhook 2>/dev/null | grep Running); do sleep 3; done

}

################################################################################
# TVK one-click upgrade code starts here
################################################################################

install_tvm

