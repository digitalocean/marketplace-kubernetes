#!/bin/sh

set -e
# set -x

################################################################################
# repo
################################################################################
helm repo add jetstack https://charts.jetstack.io
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add karvdash https://carv-ics-forth.github.io/karvdash/chart
helm repo update > /dev/null

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

get_yaml_contents () {
    yaml=$(get_yaml $1)
    if [ "${yaml:0:5}" = https ]; then
        curl -s $yaml
    else
        cat $yaml
    fi
}

install_chart () {
    helm upgrade "$STACK" "$CHART" \
    --atomic \
    --timeout 15m0s \
    --create-namespace \
    --install \
    --namespace "$NAMESPACE" \
    --values "$(get_yaml values/$STACK.yaml)" \
    --version "$CHART_VERSION" \
    $EXTRA
}

INGRESS_NAMESPACE="ingress-nginx"
JUPYTERHUB_NAMESPACE="jupyterhub"
ARGO_NAMESPACE="argo"

# cert-manager
STACK="cert-manager"
CHART="jetstack/cert-manager"
CHART_VERSION="v1.1.0"
NAMESPACE="cert-manager"
EXTRA=""
install_chart

# NGINX Ingress Controller
STACK="ingress"
CHART="ingress-nginx/ingress-nginx"
CHART_VERSION="3.19.0"
NAMESPACE=$INGRESS_NAMESPACE
EXTRA=""
install_chart

INGRESS_EXTERNAL_IP=`kubectl -n $NAMESPACE get services ingress-ingress-nginx-controller --output jsonpath='{.status.loadBalancer.ingress[0].ip}'`
if [ -z "${INGRESS_EXTERNAL_IP}" ]; then
    # use local IP for testing on Docker Desktop
    INGRESS_EXTERNAL_IP=$(ipconfig getifaddr en0 || ipconfig getifaddr en1)
fi
INGRESS_EXTERNAL_ADDRESS=${INGRESS_EXTERNAL_IP}.nip.io

if kubectl -n $NAMESPACE get secret ssl-certificate; then
    :
else
    # retry until ready (https://github.com/jetstack/cert-manager/issues/2908)
    max_attempts=5
    for i in $(seq 1 $max_attempts); do
        echo "$(get_yaml_contents yaml/ingress-certificate.yaml)" | sed "s|example.com|$INGRESS_EXTERNAL_ADDRESS|" | kubectl -n $NAMESPACE apply -f - && break
        echo "WARNING: The cert-manager webhook is not ready... Retrying in 5 seconds... (attempt $i/$max_attempts)"
        sleep 5
    done
    if [ $i = $max_attempts ]; then
        echo "ERROR: The cert-manager webhook failed to initialize after $max_attempts attempts."
        exit 1;
    fi
fi

# NFS CSI Driver
STACK="csi-driver-nfs"
CHART="csi-driver-nfs/csi-driver-nfs"
CHART_VERSION="v3.0.0"
NAMESPACE="csi-nfs"
EXTRA=""
install_chart

# NFS server
NAMESPACE="nfs"

if kubectl -n $NAMESPACE get service nfs-server; then
    :
else
    kubectl create namespace $NAMESPACE || true
    kubectl -n $NAMESPACE apply -f $(get_yaml yaml/nfs-service.yaml)
fi

# Datashim
kubectl apply -f $(get_yaml yaml/dlf-custom.yaml) # built from 079b99e with "--set csi-nfs-chart.enabled='false'" in HELM_IMAGE_TAGS
kubectl wait --timeout=600s --for=condition=ready pods -l app.kubernetes.io/name=dlf -n dlf

# Karvdash
STACK="karvdash"
CHART="karvdash/karvdash"
CHART_VERSION="3.0.1"
NAMESPACE="karvdash"
EXTRA="--set karvdash.ingressURL=https://${INGRESS_EXTERNAL_ADDRESS} \
       --set karvdash.filesURL=nfs://nfs-server.nfs.svc/exports \
       --set karvdash.jupyterHubURL=https://jupyterhub.${INGRESS_EXTERNAL_ADDRESS} \
       --set karvdash.jupyterHubNamespace=${JUPYTERHUB_NAMESPACE} \
       --set karvdash.jupyterHubNotebookDir=notebooks \
       --set karvdash.argoWorkflowsURL=https://argo.${INGRESS_EXTERNAL_ADDRESS} \
       --set karvdash.argoWorkflowsNamespace=${ARGO_NAMESPACE}"

if kubectl -n $NAMESPACE get pvc karvdash-state-pvc; then
    :
else
    kubectl create namespace $NAMESPACE || true
    kubectl -n $NAMESPACE apply -f $(get_yaml yaml/karvdash-volume.yaml)
fi

kubectl create namespace $JUPYTERHUB_NAMESPACE || true
kubectl create namespace $ARGO_NAMESPACE || true

install_chart

# JupyterHub
NAMESPACE=$JUPYTERHUB_NAMESPACE

JUPYTERHUB_CLIENT_ID=$(kubectl -n $NAMESPACE get secret karvdash-oauth-jupyterhub -o 'go-template={{index .data "client-id" | base64decode }}')
JUPYTERHUB_CLIENT_SECRET=$(kubectl -n $NAMESPACE get secret karvdash-oauth-jupyterhub -o 'go-template={{index .data "client-secret" | base64decode }}')

STACK="jupyterhub"
CHART="jupyterhub/jupyterhub"
CHART_VERSION="1.0.1"
EXTRA="--set hub.config.GenericOAuthenticator.client_id=${JUPYTERHUB_CLIENT_ID} \
       --set hub.config.GenericOAuthenticator.client_secret=${JUPYTERHUB_CLIENT_SECRET} \
       --set hub.config.GenericOAuthenticator.oauth_callback_url=https://jupyterhub.${INGRESS_EXTERNAL_ADDRESS}/hub/oauth_callback \
       --set hub.config.GenericOAuthenticator.authorize_url=https://${INGRESS_EXTERNAL_ADDRESS}/oauth/authorize/ \
       --set hub.config.GenericOAuthenticator.token_url=https://${INGRESS_EXTERNAL_ADDRESS}/oauth/token/ \
       --set hub.config.GenericOAuthenticator.userdata_url=https://${INGRESS_EXTERNAL_ADDRESS}/oauth/userinfo/ \
       --set ingress.hosts[0]=jupyterhub.${INGRESS_EXTERNAL_ADDRESS}"
install_chart

kubectl create clusterrolebinding jupyterhub-cluster-admin --clusterrole=cluster-admin --serviceaccount=$NAMESPACE:hub

# Argo Workflows
STACK="argo"
CHART="argo/argo-workflows"
CHART_VERSION="0.2.12"
NAMESPACE=$ARGO_NAMESPACE
EXTRA="--set server.volumeMounts[0].mountPath=/etc/ssl/certs/${INGRESS_EXTERNAL_ADDRESS}.crt \
       --set server.ingress.hosts[0]=argo.${INGRESS_EXTERNAL_ADDRESS} \
       --set server.sso.issuer=https://${INGRESS_EXTERNAL_ADDRESS}/oauth \
       --set server.sso.redirectUrl=https://argo.${INGRESS_EXTERNAL_ADDRESS}/oauth2/callback"

if kubectl -n $NAMESPACE get configmap ssl-certificate; then
    :
else
    kubectl -n $NAMESPACE create configmap ssl-certificate --from-literal="ca.crt=`kubectl get secret ssl-certificate -n ${INGRESS_NAMESPACE} -o 'go-template={{index .data \"ca.crt\" | base64decode }}'`"
fi

install_chart
