#!/bin/sh

set -e


################################################################################
# repo
################################################################################
helm repo add frappe-operator https://vyogotech.github.io/frappe-operator/helm-repo
helm repo add mariadb-operator https://mariadb-operator.github.io/mariadb-operator
helm repo update > /dev/null

################################################################################
# chart
################################################################################
# Bundles MariaDB Operator, KEDA, NGINX Ingress Controller, and OpenEBS NFS
STACK="frappe-operator"
CHART="frappe-operator/frappe-operator"
CHART_VERSION="5.5.2"
NAMESPACE="frappe-operator-system"

################################################################################
# KEDA: skip the bundled KEDA if the cluster already has its own
################################################################################
KEDA_ENABLED="true"
if kubectl get crd scaledobjects.keda.sh > /dev/null 2>&1; then
  KEDA_OWNER=$(kubectl get crd scaledobjects.keda.sh \
    -o jsonpath='{.metadata.annotations.meta\.helm\.sh/release-name}')
  if [ "$KEDA_OWNER" != "$STACK" ]; then
    echo "KEDA is already installed on this cluster; skipping the bundled KEDA."
    KEDA_ENABLED="false"
  fi
fi

################################################################################
# NGINX: skip the bundled NGINX if the cluster already has an NGINX ingress
# controller. Other controllers (e.g. Traefik) are left alone and ours is
# installed alongside, because sites default to the 'nginx' IngressClass.
################################################################################
NGINX_ENABLED="true"
for ic in $(kubectl get ingressclass -o name 2>/dev/null); do
  IC_OWNER=$(kubectl get "$ic" -o jsonpath='{.metadata.annotations.meta\.helm\.sh/release-name}')
  IC_CONTROLLER=$(kubectl get "$ic" -o jsonpath='{.spec.controller}')
  if [ "$IC_OWNER" != "$STACK" ] && [ "$IC_CONTROLLER" = "k8s.io/ingress-nginx" ]; then
    echo "NGINX Ingress Controller found ($ic); skipping the bundled NGINX."
    NGINX_ENABLED="false"
  fi
done

################################################################################
# NFS: skip the bundled NFS provisioner if 'nfs-rwx-storage' already exists
################################################################################
NFS_ENABLED="true"
if kubectl get storageclass nfs-rwx-storage > /dev/null 2>&1; then
  SC_OWNER=$(kubectl get storageclass nfs-rwx-storage \
    -o jsonpath='{.metadata.annotations.meta\.helm\.sh/release-name}')
  if [ "$SC_OWNER" != "$STACK" ]; then
    echo "StorageClass nfs-rwx-storage already exists; skipping the bundled NFS provisioner."
    NFS_ENABLED="false"
  fi
fi

################################################################################
# MariaDB: skip the bundled MariaDB Operator if the cluster already has its own
################################################################################
MARIADB_ENABLED="true"
if kubectl get crd mariadbs.k8s.mariadb.com > /dev/null 2>&1; then
  MDB_OWNER=$(kubectl get crd mariadbs.k8s.mariadb.com \
    -o jsonpath='{.metadata.annotations.meta\.helm\.sh/release-name}')
  MDB_OWNER_NS=$(kubectl get crd mariadbs.k8s.mariadb.com \
    -o jsonpath='{.metadata.annotations.meta\.helm\.sh/release-namespace}')
  if [ "$MDB_OWNER" != "mariadb-operator-crds" ] || [ "$MDB_OWNER_NS" != "$NAMESPACE" ]; then
    echo "MariaDB Operator is already installed on this cluster; skipping the bundled MariaDB Operator."
    MARIADB_ENABLED="false"
  fi
fi

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  values="$ROOT_DIR/stacks/frappe-operator/values.yml"
else
  # use github hosted master version of values.yml
  values="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/frappe-operator/values.yml"
fi

################################################################################
# MariaDB CRDs: own release, so uninstalling the stack never deletes databases
################################################################################
if [ "$MARIADB_ENABLED" = "true" ]; then
  helm upgrade mariadb-operator-crds mariadb-operator/mariadb-operator-crds \
    --create-namespace \
    --install \
    --namespace "$NAMESPACE" \
    --version 0.34.0
fi

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --set keda.enabled="$KEDA_ENABLED" \
  --set mariadb-operator.enabled="$MARIADB_ENABLED" \
  --set ingress-nginx.enabled="$NGINX_ENABLED" \
  --set openebs-nfs.enabled="$NFS_ENABLED" \
  --version "$CHART_VERSION"
