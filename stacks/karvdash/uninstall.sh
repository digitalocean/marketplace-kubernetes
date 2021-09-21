#!/bin/sh

set -e
# set -x

################################################################################
# charts
################################################################################

get_yaml () {
    local yaml
    if [ -z "${MP_KUBERNETES}" ]; then
        # use local version
        ROOT_DIR=$(git rev-parse --show-toplevel)
        yaml="$ROOT_DIR/stacks/karvdash/$1"
    else
        # use github hosted master version
        yaml="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/karvdash/$1"
    fi
    echo "$yaml"
}

uninstall_chart () {
    helm uninstall "$STACK" --namespace "$NAMESPACE" || true
    if [ $NAMESPACE != "default" ]; then
        kubectl delete namespace $NAMESPACE || true
    fi
}

# Argo Workflows
STACK="argo"
NAMESPACE="argo"
uninstall_chart

# JupyterHub
STACK="jupyterhub"
NAMESPACE="jupyterhub"
uninstall_chart

kubectl delete clusterrolebinding jupyterhub-cluster-admin

# Karvdash
STACK="karvdash"
NAMESPACE="karvdash"

for i in `kubectl get namespaces -o jsonpath='{.items[*].metadata.name}'`; do
    if echo $i | grep "^karvdash-" > /dev/null; then
        kubectl delete ns $i # clean up user namespaces
        for j in `kubectl get pv -o jsonpath='{.items[*].metadata.name}'`; do
            if echo $j | grep "^$i" > /dev/null; then
                kubectl delete pv $j # clean up user persistent volumes
                continue
            fi
            if [ "`kubectl get pv $j -o jsonpath='{.spec.claimRef.namespace}'`" = "$i" ]; then
                kubectl delete pv $j # clean up dataset persistent volumes
            fi
        done
    fi
done

uninstall_chart

# Datashim
kubectl delete -f $(get_yaml yaml/dlf-custom.yaml) || true

# NFS server
NAMESPACE="nfs"
kubectl delete ns $NAMESPACE || true

# NFS CSI Driver
STACK="csi-driver-nfs"
NAMESPACE="csi-nfs"
uninstall_chart

# NGINX Ingress Controller
STACK="ingress"
NAMESPACE="ingress-nginx"
uninstall_chart

# cert-manager
STACK="cert-manager"
NAMESPACE="cert-manager"
uninstall_chart
