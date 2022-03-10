# Description

Linkerd is an ultralight service mesh for Kubernetes. It makes running services easier and safer by giving you runtime debugging, observability, metrics, reliability, and security without requiring any code changes. And now, the Buoyant Linkerd 1-Click App configures and performs a recommended deployment of [Linkerd2](https://linkerd.io/?utm_source=DigitalOcean&utm_campaign=Marketplace) onto a DigitalOcean Kubernetes cluster, in the linkerd namespace. It's all done for you, in mere minutes.

The Linkerd2 CLI is recommended to interact with Linkerd2 and instructions are provided to add your specific service. As a part of a recommended deployment this 1-click contains Grafana and Prometheus included in the linkerd namespace.

This stack source is open source and community supported, and can be found at [github.com/digitalocean/marketplace-kubernetes/tree/master/stacks/linkerd2](https://github.com/digitalocean/marketplace-kubernetes/tree/master/stacks/linkerd2). Contributions on bug fixes and features will be kindly reviewed. If you have large production needs and would like a trusted services and support partner by your side Buoyant - makers of Linkerd - have the [Buoyant Enterprise Support](https://buoyant.io/commercial-support/?utm_source=DigitalOcean&utm_campaign=Marketplace) subscription just for you.

Note: This stack requires a minimum configuration of 2 Nodes at the $10/month plan (2GB memory / 1 vCPU).

## Software included

| Package               | Application Version   |License                                                                                    |
| ---| ---- | ------------- |
| linkerd2 | [2.11.1](https://github.com/linkerd/linkerd2/releases/tag/stable-2.11.1) | [Apache 2.0](https://github.com/linkerd/linkerd2/blob/master/LICENSE) |

## Getting Started

### How to Connect to Your Cluster

As you get started with Kubernetes on DigitalOcean be sure to check out how to connect to your cluster using `kubectl` and `doctl`:
<https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/>

Additional instructions for configuring the [DigitalOcean Kubernetes](https://cloud.digitalocean.com/kubernetes/clusters/):

- [How to Set Up a DigitalOcean Managed Kubernetes Cluster (DOKS)](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/01-setup-DOKS#how-to-set-up-a-digitalocean-managed-kubernetes-cluster-doks)
- [How to Set up DigitalOcean Container Registry](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/02-setup-DOCR#how-to-set-up-digitalocean-container-registry)

### How to confirm that Linkerd is running

First, check if the Linkerd installation was successful, by running below command:

```bash
kubectl get deployment -n linkerd
```

The output looks similar to (all Pods should be in a `READY` state:

```text
NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
linkerd-destination      1/1     1            1           4m6s
linkerd-identity         1/1     1            1           4m11s
linkerd-proxy-injector   1/1     1            1           4m3s
```

Next, check if the Linkerd on-cluster metrics stack installation was successful, by running below command:

```bash
kubectl get deployment -n linkerd-viz
```

The output looks similar to (all Pods should be in a `READY` state:

```text
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
grafana        1/1     1            1           7m36s
metrics-api    1/1     1            1           7m40s
prometheus     1/1     1            1           7m33s
tap            1/1     1            1           7m31s
tap-injector   1/1     1            1           7m23s
web            1/1     1            1           7m11s
```

### Install the Linkerd CLI

If this is your first time running Linkerd, you’ll need to download the command line interface (CLI) onto your local machine. You’ll use this CLI to interact with Linkerd.

**Note:**

Instructions here are for MacOS and Linux. For instructions on other Operating Systems see the [release page](https://github.com/linkerd/linkerd2/releases/).

Download and install the Linkerd client binary:

```console
curl -sL https://run.linkerd.io/install | sh
```

Next, add Linkerd to your path:

```console
export PATH=$PATH:$HOME/.linkerd2/bin
```

Verify that the CLI is installed by running:

```console
linkerd version
```

### Explore Linkerd

With the control plane installed and running, you can now view the Linkerd dashboard by running:

```console
linkerd viz dashboard
```

This will open your default browser and load your Linkerd dashboard.

- Linkerd also includes Grafana to visualize all the great metrics collected by Prometheus and ships with some extremely valuable dashboards.
- Grafana dashboard available at: <http://localhost:50750/grafana>

### Adding your services to Linkerd

In order for your service to take advantage of Linkerd, it needs to have the proxy sidecar added to its resource definition. This is done by using the Linkerd CLI to update the definition and output YAML that can be passed to kubectl. By using Kubernetes’ rolling updates, the availability of your application will not be affected.

To add Linkerd to your service, run:

```console
linkerd inject deployment.yml | kubectl apply -f -
```

For more details please visit [official documentation](https://linkerd.io/2.11/tasks/adding-your-service/#)

### Upgrading the Linkerd CLI

This will upgrade your local CLI to the latest version:

```console
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh
```

**Note:**

Alternatively, you can download the CLI directly via the [Linkerd releases page](https://github.com/linkerd/linkerd2/releases/).

Verify the CLI is installed and running correctly with:

```console
linkerd version --client
```

Which should display:

```text
Client version: stable-2.11.1
```

### Upgrading the Linkerd Control Plane

Use the linkerd upgrade command to upgrade the control plane. This command ensures that all of the control plane’s existing configuration and mTLS secrets are retained. Notice that we use the --prune flag to remove any Linkerd resources from the previous version which no longer exist in the new version.

```console
linkerd upgrade | kubectl apply --prune -l linkerd.io/control-plane-ns=linkerd -f -
```

Next, run this command again with some --prune-whitelist flags added. This is necessary to make sure that certain cluster-scoped resources are correctly pruned.

```console
linkerd upgrade | kubectl apply --prune -l linkerd.io/control-plane-ns=linkerd \
  --prune-whitelist=rbac.authorization.k8s.io/v1/clusterrole \
  --prune-whitelist=rbac.authorization.k8s.io/v1/clusterrolebinding \
  --prune-whitelist=apiregistration.k8s.io/v1/apiservice -f -
```

**Note:**

For upgrading a multi-stage installation setup, follow the instructions at [Upgrading a multi-stage install](https://linkerd.io/2.11/tasks/upgrade/#upgrading-a-multi-stage-install).

Finally, check the control plane upgrade:

```console
linkerd check
```

**Note:**

This will run through a set of checks against your control plane and make sure that it is operating correctly.

### Uninstalling the Linkerd

Removing Linkerd from a Kubernetes cluster requires a few steps:

- removing any data plane proxies
- removing all the extensions and then removing the core control plane.

#### Removing Linkerd data plane proxies

To remove any extension, call its uninstall subcommand and pipe it to `kubectl delete -f -`

```console
linkerd viz uninstall | kubectl delete -f -
```

#### Removing Linkerd control plane

To remove the control plane run:

```console
linkerd uninstall | kubectl delete -f -
```

**Note:**

The `linkerd uninstall` command outputs the manifest for all of the Kubernetes resources necessary for the control plane, including namespaces, service accounts, CRDs, and more; `kubectl delete` then deletes those resources.

### Additional Resources

To further enrich your experience, you can also visit the official Linkerd documentation sites:

- [Documentation](https://linkerd.io/2.11/overview/)
