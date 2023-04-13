# Description

[Linkerd](https://linkerd.io/?utm_source=DigitalOcean&utm_campaign=Marketplace) is an ultralight service mesh for Kubernetes. It makes running services easier and safer by giving you runtime debugging, observability, metrics, reliability, and security without requiring any code changes. The Linkerd 1-Click app configures and performs a deployment of Linkerd2 onto a DigitalOcean Kubernetes cluster in the `linkerd` namespace. As a part of a recommended deployment, this app includes Grafana and Prometheus in the `linkerd` namespace.

This stack is open source and community supported, and can be found at [github.com/digitalocean/marketplace-kubernetes/tree/master/stacks/linkerd2](https://github.com/digitalocean/marketplace-kubernetes/tree/master/stacks/linkerd2). If you have large production needs, see the [Buoyant Enterprise Support](https://buoyant.io/commercial-support/?utm_source=DigitalOcean&utm_campaign=Marketplace).

**Notes:**

- The Linkerd2 CLI is recommended to interact with Linkerd2 and instructions are provided to add your specific service.

- This stack requires a minimum configuration of 2 nodes at the $10/month plan (2GB memory/1 vCPU).

## Software included

| Package               | Application Version   |License                                                                                    |
| ---| ---- | ------------- |
| linkerd2 | [2.11.4](https://github.com/linkerd/linkerd2/releases/tag/stable-2.11.4) | [Apache 2.0](https://github.com/linkerd/linkerd2/blob/master/LICENSE) |

## Getting Started

### How to Connect to Your Cluster

Follow these [instructions](https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/) to connect to your cluster with `kubectl` and `doctl`.

### Confirming that Linkerd is Running

First, check if the Linkerd installation was successful by running the command below:

```bash
kubectl get deployment -n linkerd
```

The output looks similar to the following:

```text
NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
linkerd-destination      1/1     1            1           4m6s
linkerd-identity         1/1     1            1           4m11s
linkerd-proxy-injector   1/1     1            1           4m3s
```

All pods should be in a `READY` state.
  
Next, check if the Linkerd on-cluster metrics stack installation was successful by running the following command:

```bash
kubectl get deployment -n linkerd-viz
```

The output looks similar to the following:

```text
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
grafana        1/1     1            1           7m36s
metrics-api    1/1     1            1           7m40s
prometheus     1/1     1            1           7m33s
tap            1/1     1            1           7m31s
tap-injector   1/1     1            1           7m23s
web            1/1     1            1           7m11s
```

All pods should be in a `READY` state.
  
### Installing the Linkerd Command Line Interface

If this is your first time running Linkerd, you will need to download the command line interface (CLI) onto your local machine to interact with Linkerd.

For installation instructions, see the [release page](https://github.com/linkerd/linkerd2/releases/). For example, for MacOS and Linux, download and install the Linkerd client binary:

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

The output looks similar to the following:

```text
Client version: stable-2.11.2
Server version: stable-2.11.4
```

You can now view the Linkerd dashboard by running:

```console
linkerd viz dashboard
```

This will open your default browser with the Linkerd dashboard.

Linkerd also includes Grafana to visualize all the metrics collected by Prometheus. You can see the Grafana dashboard at <http://localhost:50750/grafana>.

### Adding Your Services to Linkerd

In order for your service to use Linkerd, it needs to have the proxy sidecar added to its resource definition. To do so, use the Linkerd CLI to update the definition and output YAML files and pass them to `kubectl`. By using Kubernetes rolling updates, the availability of your application will not be affected.

To add Linkerd to your service, run:

```console
linkerd inject deployment.yml | kubectl apply -f -
```

For more details, see [the Linkerd documentation](https://linkerd.io/2.11/tasks/adding-your-service/#).

### Upgrading the Linkerd CLI

To upgrade your local CLI to the latest version, run the following command:

```console
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh
```

Alternatively, you can download the CLI directly via the [Linkerd releases page](https://github.com/linkerd/linkerd2/releases/).

Verify the CLI is installed and running correctly by running the following command:

```console
linkerd version --client
```

The output looks similar to the following:

```text
Client version: stable-2.11.2
```

### Upgrading the Linkerd Control Plane

Use the `linkerd upgrade` command to upgrade the control plane. This command ensures that all of the control plane’s existing configuration and mTLS secrets are retained. Use the `--prune` flag to remove any Linkerd resources from the previous version which no longer exist in the new version.

```console
linkerd upgrade | kubectl apply --prune -l linkerd.io/control-plane-ns=linkerd -f -
```

Next, run this command again by adding some `--prune-whitelist` flags. This makes sure that certain cluster-scoped resources are correctly pruned.

```console
linkerd upgrade | kubectl apply --prune -l linkerd.io/control-plane-ns=linkerd \
  --prune-whitelist=rbac.authorization.k8s.io/v1/clusterrole \
  --prune-whitelist=rbac.authorization.k8s.io/v1/clusterrolebinding \
  --prune-whitelist=apiregistration.k8s.io/v1/apiservice -f -
```

**Note:**

For upgrading a multi-stage installation setup, follow the [upgrading a multi-stage install](https://linkerd.io/2.11/tasks/upgrade/#upgrading-a-multi-stage-install) instructions.

Finally, check that the control plane has been upgraded:

```console
linkerd check
```

**Note:**

This will run through a set of checks against your control plane and make sure that it is operating correctly.

### Uninstalling Linkerd

To uninstall Linkerd from a Kubernetes cluster, you need to first remove any data plane proxies and extensions by running the following command:

```console
linkerd viz uninstall | kubectl delete -f -
```

Next, remove the control plane by running the following command:

```console
linkerd uninstall | kubectl delete -f -
```

**Note:** The `linkerd uninstall` command outputs the manifest for all of the Kubernetes resources necessary for the control plane, including namespaces, service accounts, CRDs, and more; `kubectl delete` then deletes those resources.

### Additional Resources

For further study, see the following:

- [How to Set Up a DigitalOcean Managed Kubernetes Cluster (DOKS)](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/01-setup-DOKS#how-to-set-up-a-digitalocean-managed-kubernetes-cluster-doks)
- [How to Set up DigitalOcean Container Registry](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/02-setup-DOCR#how-to-set-up-digitalocean-container-registry)
- [Linkerd Documentation](https://linkerd.io/2.11/overview/)
