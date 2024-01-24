# Dashboard 1-click for DigitalOcean Kubernetes

This addon allows you to easily install the Kubernetes Dashboard Helm chart on your DigitalOcean Kubernetes cluster. 

The Kubernetes Dashboard offers a user-friendly, web-based interface for managing and monitoring your Kubernetes cluster. It allows you to:
- Visualize your cluster resources, including pods, deployments, services, and nodes.
- Debug applications by viewing logs and resource metrics.
- Manage deployments, rolling updates, and service configuration.
- Gain insights into cluster health and performance.

## Prerequisites

Before using this addon, please ensure the following prerequisites are met:

1. **Helm 3:** Make sure you have Helm 3 installed on your local machine.

2. **Kubernetes Cluster:** Ensure that you have access to your DigitalOcean Kubernetes cluster, and your kubeconfig is properly configured to interact with the cluster.

## Installation

You can install the Kubernetes Dashboard by following these steps:

1. Verify your DigitalOcean Kubernetes cluster's version:

   ```bash
   kubectl version --short
   ```

2. Run **deploy.sh**. This basically runs the following. Note that we are explicitly installing the latest version of the dashboard. 

   ```bash
   helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
     --create-namespace \
     --namespace kubernetes-dashboard \
     --set app.ingress.enabled=false \
     --set metrics-server.enabled=false \
     --set cert-manager.enabled=false \
     --set nginx.enabled=false
   ```

4. Port-forward the Kubernetes Dashboard to your local machine:

   ```bash
   export POD_NAME=$(kubectl get pods -n kubernetes-dashboard -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}")
   kubectl -n kubernetes-dashboard port-forward $POD_NAME 8443:8443
   ```

5. Access the Kubernetes Dashboard from your local browser at `https://127.0.0.1:8443/`. You may encounter a certificate warning, so make sure to override it.

6. To authenticate, use the Kubernetes configuration file for your cluster, which can be downloaded from the DigitalOcean Kubernetes cloud console for your cluster. You need to choose "manual authentication" and then you can see the option to download the config file.

## Custom Configuration

If you want to reinstall the Kubernetes Dashboard with custom configuration, follow these steps:

1. Update the `values.yaml` file to your preferences. [Reference values.yaml](https://raw.githubusercontent.com/kubernetes/dashboard/master/charts/helm-chart/kubernetes-dashboard/values.yaml)

2. Upgrade the Kubernetes Dashboard with **upgrade.sh** script. That essentially runs the following.

   ```bash
   helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
     --create-namespace \
     --namespace kubernetes-dashboard -f values.yaml
   ```

## Uninstallation

To remove the Kubernetes Dashboard Helm chart, use ./uninstall.sh script. That runs the following command.

```bash
helm uninstall kubernetes-dashboard -n kubernetes-dashboard
```

Please note that the dashboard installed by default does not have a public endpoint. If you require one, you'll need to install Nginx, Cert-Manager, and configure the `values.yaml` file as part of the installation process.

For more information about the Kubernetes Dashboard, refer to the [official documentation](https://github.com/kubernetes/dashboard/releases/tag/v3.0.0-alpha0) or the Helm chart on [ArtifactHub](https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard).

