#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add triliovault-operator http://charts.k8strilio.net/trilio-stable/k8s-triliovault-operator --force-update
helm repo update > /dev/null

################################################################################
# TVK Operator chart upgrade
################################################################################
STACK="triliovault-operator"
CHART="triliovault-operator/k8s-triliovault-operator"

LATEST="$(helm show chart triliovault-operator/k8s-triliovault-operator | grep appVersion | awk -F ':' '{gsub(/ /,""); print $2 }')"
echo "Upgrading TVK to latest version: $LATEST"
CHART_VERSION=$LATEST
NAMESPACE="trilio-system"
WEBHOOK_ABSENT_GRACE_TRIES="${TVK_WEBHOOK_ABSENT_GRACE_TRIES:-20}"
WEBHOOK_READY_TIMEOUT_TRIES="${TVK_WEBHOOK_READY_TIMEOUT_TRIES:-100}"
WEBHOOK_WAIT_INTERVAL_SECONDS="${TVK_WEBHOOK_WAIT_INTERVAL_SECONDS:-3}"

# Upgrade triliovault operator
echo "Upgrading Triliovault operator..."

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  TVK_PATH="$ROOT_DIR/stacks/$STACK"
  TVK_LICENSE_FILE="$TVK_PATH/tvk_install_license.yaml"
  values="$TVK_PATH/values.yml"
  TVM="$TVK_PATH/triliovault-manager.yaml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/triliovault-operator/values.yml"
  TVM="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/triliovault-operator/triliovault-manager.yaml"
  TVK_LICENSE_FILE="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/triliovault-operator/tvk_install_license.yaml"
fi

helm upgrade "$STACK" "$CHART" \
  --rollback-on-failure \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"

retcode=$?
if [ "$retcode" -ne 0 ]; then
  echo "There is some error during triliovault-operator upgrade using helm, please contanct Trilio support"
  return 1
fi

until (kubectl get pods --namespace "$NAMESPACE" -l "release=triliovault-operator" 2>/dev/null | grep Running); do
  echo "Waiting for TrilioVault operator (release=triliovault-operator)..."
  kubectl get pods --namespace "$NAMESPACE" -l "release=triliovault-operator" 2>/dev/null || true
  sleep 3
done

################################################################################
# TVK Manager Upgrade
################################################################################

install_tvm () {
  # Upgrade triliovault manager
  echo "Upgrading Triliovault manager..."
  
  # Replace TVM.yaml with latest version
  sed -i '/^spec:/{n;s/trilioVaultAppVersion:.*/trilioVaultAppVersion: '$LATEST'/;}' "$TVK_PATH/triliovault-manager.yaml"

  kubectl apply -f "$TVM" --namespace "$NAMESPACE"
  retcode=$?

  if [ "$retcode" -ne 0 ];then
    echo "Some error occurred during triliovault-manager installation using label definition, please contanct Trilio support"
    return 1
  fi

  until (kubectl get pods --namespace "$NAMESPACE" -l "triliovault.trilio.io/owner=triliovault-manager" 2>/dev/null | grep Running); do
    echo "Waiting for TrilioVault Manager workloads..."
    kubectl get pods --namespace "$NAMESPACE" -l "triliovault.trilio.io/owner=triliovault-manager" 2>/dev/null || true
    sleep 3
  done
  until (kubectl get pods --namespace "$NAMESPACE" -l app=k8s-triliovault-exporter 2>/dev/null | grep 1/1); do
    echo "Waiting for k8s-triliovault-exporter..."
    kubectl get pods --namespace "$NAMESPACE" -l app=k8s-triliovault-exporter 2>/dev/null || true
    sleep 3
  done
  until (kubectl get pods --namespace "$NAMESPACE" -l "app.kubernetes.io/name=k8s-triliovault-ingress-nginx" 2>/dev/null | grep 1/1); do
    echo "Waiting for k8s-triliovault-ingress-nginx..."
    kubectl get pods --namespace "$NAMESPACE" -l "app.kubernetes.io/name=k8s-triliovault-ingress-nginx" 2>/dev/null || true
    sleep 3
  done
  until (kubectl get pods --namespace "$NAMESPACE" -l app=k8s-triliovault-web 2>/dev/null | grep 1/1); do
    echo "Waiting for k8s-triliovault-web..."
    kubectl get pods --namespace "$NAMESPACE" -l app=k8s-triliovault-web 2>/dev/null || true
    sleep 3
  done
  until (kubectl get pods --namespace "$NAMESPACE" -l app=k8s-triliovault-web-backend 2>/dev/null | grep 1/1); do
    echo "Waiting for k8s-triliovault-web-backend..."
    kubectl get pods --namespace "$NAMESPACE" -l app=k8s-triliovault-web-backend 2>/dev/null || true
    sleep 3
  done
  until (kubectl get pods --namespace "$NAMESPACE" -l app=k8s-triliovault-control-plane --no-headers 2>/dev/null | awk '$2 ~ "^[0-9]+/[0-9]+$" { n = split($2, a, "/"); if (n == 2 && a[1] == a[2] && a[1] > 0) found = 1 } END { exit found ? 0 : 1 }'); do
    echo "Waiting for k8s-triliovault-control-plane..."
    kubectl get pods --namespace "$NAMESPACE" -l app=k8s-triliovault-control-plane 2>/dev/null || true
    sleep 3
  done
  webhook_wait_tries=0
  until (kubectl get pods --namespace "$NAMESPACE" -l app=k8s-triliovault-admission-webhook --no-headers 2>/dev/null | awk '$2 ~ "^[0-9]+/[0-9]+$" { n = split($2, a, "/"); if (n == 2 && a[1] == a[2] && a[1] > 0) found = 1 } END { exit found ? 0 : 1 }'); do
    webhook_wait_tries=$((webhook_wait_tries + 1))
    echo "Waiting for k8s-triliovault-admission-webhook..."
    webhook_pods="$(kubectl get pods --namespace "$NAMESPACE" -l app=k8s-triliovault-admission-webhook --no-headers 2>/dev/null || true)"
    if [ -z "$webhook_pods" ] && [ "$webhook_wait_tries" -ge "$WEBHOOK_ABSENT_GRACE_TRIES" ]; then
      echo "k8s-triliovault-admission-webhook pods not found after grace period; continuing without this optional wait."
      break
    fi
    kubectl get pods --namespace "$NAMESPACE" -l app=k8s-triliovault-admission-webhook 2>/dev/null || true
    if [ "$webhook_wait_tries" -ge "$WEBHOOK_READY_TIMEOUT_TRIES" ]; then
      echo "Timed out waiting for k8s-triliovault-admission-webhook to become ready."
      return 1
    fi
    sleep "$WEBHOOK_WAIT_INTERVAL_SECONDS"
  done
}

################################################################################
# TVK one-click upgrade code starts here
################################################################################

install_tvm
