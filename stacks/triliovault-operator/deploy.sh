#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add triliovault-operator http://charts.k8strilio.net/trilio-stable/k8s-triliovault-operator --force-update
helm repo update > /dev/null

################################################################################
# TVK Operator chart installation
################################################################################
STACK="triliovault-operator"
CHART="triliovault-operator/k8s-triliovault-operator"

LATEST="$(helm show chart triliovault-operator/k8s-triliovault-operator | grep appVersion | awk -F ':' '{gsub(/ /,""); print $2 }')"
echo "Installing TVK version: $LATEST"
CHART_VERSION=$LATEST
NAMESPACE="trilio-system"
INSTALL_TVM=true
TVK_HOSTNAME="tvk.doks.com"
TVK_INSTANCE_NAME="tvk-instance-digital-ocean"
INGRESS_SERVICE_TYPE="NodePort"
WEBHOOK_ABSENT_GRACE_TRIES="${TVK_WEBHOOK_ABSENT_GRACE_TRIES:-20}"
WEBHOOK_READY_TIMEOUT_TRIES="${TVK_WEBHOOK_READY_TIMEOUT_TRIES:-100}"
WEBHOOK_WAIT_INTERVAL_SECONDS="${TVK_WEBHOOK_WAIT_INTERVAL_SECONDS:-3}"
LICENSE_WAIT_TIMEOUT_TRIES="${TVK_LICENSE_WAIT_TIMEOUT_TRIES:-120}"
LICENSE_WAIT_INTERVAL_SECONDS="${TVK_LICENSE_WAIT_INTERVAL_SECONDS:-3}"
LICENSE_JOB_NAME="${TVK_LICENSE_JOB_NAME:-tvk-license-do}"

# Install triliovault operator and triliovault manager
echo "Installing TrilioVault operator and TrilioVault Manager with one-click install functionality"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  TVK_PATH="$ROOT_DIR/stacks/$STACK"
  TVK_LICENSE_FILE="$TVK_PATH/tvk_install_license.yaml"
  values="$TVK_PATH/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/triliovault-operator/values.yml"
  TVK_LICENSE_FILE="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/triliovault-operator/tvk_install_license.yaml"
fi

helm upgrade "$STACK" "$CHART" \
  --rollback-on-failure \
  --create-namespace \
  --install \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION" \
  --set installTVK.enabled="$INSTALL_TVM" \
  --set installTVK.ingressConfig.host="$TVK_HOSTNAME" \
  --set installTVK.tvkInstanceName="$TVK_INSTANCE_NAME" \
  --set installTVK.ComponentConfiguration.ingressController.service.type="$INGRESS_SERVICE_TYPE"

retcode=$?
if [ "$retcode" -ne 0 ]; then
  echo "There is some error during triliovault-operator installation using helm, please contanct Trilio support"
  return 1
fi

until (kubectl get pods --namespace "$NAMESPACE" -l "release=triliovault-operator" 2>/dev/null | grep Running); do
  echo "Waiting for TrilioVault operator (release=triliovault-operator)..."
  kubectl get pods --namespace "$NAMESPACE" -l "release=triliovault-operator" 2>/dev/null || true
  sleep 3
done

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
# READY n/n when all containers are ready (1/1 or 2/2 depending on chart version).
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
    exit 1
  fi
  sleep "$WEBHOOK_WAIT_INTERVAL_SECONDS"
done

################################################################################
# Enable TVK Management Console using NodePort
################################################################################

access_tvk_ui () {

  echo ""
  echo "################################################################################"
  echo "TVK UI will be configured with NodePort but if you are not able to access it, please run below command to use port-forward from the machine you are accessing the TVK UI from."
  echo ""
  echo "kubectl port-forward --address 0.0.0.0 svc/k8s-triliovault-ingress-nginx-controller --namespace $NAMESPACE 80:80 &"
  echo ""
  echo "Copy & paste the above command into the terminal session and TVK management console traffic will be forwarded to your localhost IP of 127.0.0.1 via port 80."
  echo "Provide the kubeconfig file which can be downloaded from DOKS cluster UI"
  echo "################################################################################"
  echo ""

  controller=$(kubectl get pods --no-headers=true --namespace "$NAMESPACE" 2>/dev/null | awk '/k8s-triliovault-ingress-nginx-controller/{print $1}')

  if [ -z "$controller" ]; then
    echo "Not able to find k8s-triliovault-ingress-nginx-controller resource,TVK UI configuration failed"
    return 1
  fi

  node=$(kubectl get pods "$controller" --namespace "$NAMESPACE" -o jsonpath='{.spec.nodeName}')
  ip=$(kubectl get node "$node" --namespace "$NAMESPACE" -o jsonpath='{.status.addresses[?(@.type=="ExternalIP")].address}')

  if [ -z "$ip" ]; then
    echo "ExternalIP for the node does not exists, so using InternalIP"
    ip=$(kubectl get node "$node" --namespace "$NAMESPACE" -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
  fi

  port=$(kubectl get svc k8s-triliovault-ingress-nginx-controller --namespace "$NAMESPACE" -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')

  echo ""
  echo "################################################################################"
  echo "Please add '$ip $TVK_HOSTNAME' entry to your /etc/hosts file before launching the management console"
  echo "After creating an entry, TVK UI can be accessed through http://$TVK_HOSTNAME:$port/login"
  echo ""
  echo "If you still face issues while access UI, please refer - https://docs.trilio.io/kubernetes/management-console/user-interface/accessing-the-ui"
  echo "################################################################################"
}

################################################################################
# Install TVK License
################################################################################

install_license () {
  #This module is use to install license
  echo "Installing Freetrial license..."
  kubectl apply -f "$TVK_LICENSE_FILE" --namespace "$NAMESPACE"
  
  sleep 5
  echo "Verifying license generation job..."
  license_wait_tries=0
  until (kubectl get pods --namespace "$NAMESPACE" -l "job-name=$LICENSE_JOB_NAME" 2>/dev/null | grep Completed >/dev/null) || [ "$(kubectl get license trilio-license --namespace "$NAMESPACE" -o 'jsonpath={.status.status}' 2>/dev/null || true)" = "Active" ]; do
    license_wait_tries=$((license_wait_tries + 1))
    echo "Waiting for license job '$LICENSE_JOB_NAME' (or Active license status)..."
    kubectl get pods --namespace "$NAMESPACE" -l "job-name=$LICENSE_JOB_NAME" 2>/dev/null || true
    if [ "$license_wait_tries" -ge "$LICENSE_WAIT_TIMEOUT_TRIES" ]; then
      echo "Timed out waiting for license generation."
      echo "Diagnostic jobs that might be related to license:"
      kubectl get jobs --namespace "$NAMESPACE" 2>/dev/null | awk 'NR==1 || /[Ll]icense|tvk/' || true
      return 1
    fi
    sleep "$LICENSE_WAIT_INTERVAL_SECONDS"
  done

  echo "Verifying license status on namespace $NAMESPACE ..."
  lic_status=$(kubectl get license trilio-license --namespace "$NAMESPACE" -o 'jsonpath={.status.status}')
  exp_status="Active"

  if [ "$lic_status" != "$exp_status" ] ; then
    printf 'License installation failed, license status is %s\n' "$lic_status"
  else
    printf 'License is installed successfully, license status is %s\n' "$lic_status"
  fi

}

################################################################################
# TVK one-click installation code starts here
################################################################################

access_tvk_ui
install_license
