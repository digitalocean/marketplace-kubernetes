# Description

[Loki](https://grafana.com/oss/loki/) is a horizontally-scalable, highly-available, multi-tenant log aggregation system inspired by [Prometheus](https://prometheus.io/).

Compared to other log aggregation systems, Loki:

* Indexes a set of labels for each log stream, instead of indexing the context of logs.
* Indexes and groups log streams using the same labels as Prometheus.
* Automatically scrapes and indexes Kubernetes](https://kubernetes.io/) metadata, such as pod logs.
* Has native support in Grafana v6.0.

A Loki-based logging stack consists of 3 components:

* Promtail is the agent, responsible for gathering logs and sending them to Loki.
* Loki is the main server, responsible for storing logs and processing queries.
* Grafana is platform, responsible for querying and displaying the logs.

**Notes:**

* This stack requires a minimum configuration of two nodes at the $10/month plan (2GB memory / 1 vCPU).
* The Loki stack 1-Click App also includes a $1/month block storage for Loki time series database (starting at PVs of 5GB).

## Software Included

| Package               | Application Version   | Helm Chart Version |License                                                                                    |
| ---| ---- | ---- | ------------- |
| Loki Stack | 2.1.0 | [2.5.1](https://artifacthub.io/packages/helm/grafana/loki-stack/2.5.1) | [Apache 2.0](https://github.com/grafana/loki/blob/main/LICENSE) |

## Getting Started

### Getting Started with DigitalOcean Kubernetes

You can connect to your DigitalOcean Kubernetes cluster by following our [how-to guide](https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/).

For additional instructions on configuring a [DigitalOcean Kubernetes](https://cloud.digitalocean.com/kubernetes/clusters/) cluster, see the following guides:

* [How to Set Up a DigitalOcean Managed Kubernetes Cluster (DOKS)](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/01-setup-DOKS#how-to-set-up-a-digitalocean-managed-kubernetes-cluster-doks)
* [How to Set up DigitalOcean Container Registry](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/02-setup-DOCR#how-to-set-up-digitalocean-container-registry)

### Confirming that Loki Stack is Running

First, verify that the Helm installation was successful by running following command:

```bash
helm ls -n loki-stack
```

If the installation was successful, the `STATUS` column value in the output reads `deployed`:

```text
NAME NAMESPACE  REVISION UPDATED                              STATUS   CHART            APP VERSION
loki loki-stack 1        2022-02-16 14:47:29.497728 +0200 EET deployed loki-stack-2.5.1 v2.1.0
```

Next, verify that the Loki pods are up and running with the following command:

```console
kubectl get pods -n loki-stack
```

If they're running, all pods listed in the output are in a `READY` state and the `STATUS` for each reads `Running`:

```text
NAME                           READY   STATUS    RESTARTS   AGE
loki-0                         1/1     Running   0          20h
loki-promtail-kvjxr            1/1     Running   0          20h
loki-promtail-nc7zg            1/1     Running   0          20h
loki-promtail-strvq            1/1     Running   0          20h
```

### Configuring Grafana with Loki

First, expose the Grafana web interface on your local machine:

**Note:**

`Grafana` isn't installed by default when the `Loki Stack` 1-Click App is installed and needs to be installed. We recommend installing the [Kubernetes Monitoring Stack](https://marketplace.digitalocean.com/apps/kubernetes-monitoring-stack) 1-Click App, which includes `Grafana` and its monitoring components.

To access the Grafana Web Panel, run the following command using the default credentials `admin/prom-operator`:

```console
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n kube-prometheus-stack
```

Navigate to <http://localhost:80/> and login with admin and the password (default credentials: admin/prom-operator). Then, follow the instructions for adding the Loki datasource, using the URL <http://loki.loki-stack:3100>.

For more details about deployment status and functionality, see the [Loki tutorial](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/05-setup-loki-stack/README.md).

### Tweaking Helm Values

The `loki-stack` has custom default Helm values. See the [values](./values.yml) file from the main GitHub repository.

To inspect the stack's current values, run the following command:

```console
helm show values grafana/loki-stack --version 2.5.1
```

To change these values, open the Helm values file `values.yml`, change whatever values you want, save and exit the file, and apply the changes by running `helm upgrade` command:

```console
helm upgrade loki grafana/loki-stack --version 2.5.1 \
  --namespace loki-stack \
  --values values.yml
```

### Upgrading the Loki Stack Chart

YYou can check what versions are available to upgrade by navigating to the [loki-stack](https://github.com/grafana/loki/releases) official releases page from GitHub. Alternatively, you can use [ArtifactHUB](https://artifacthub.io/packages/helm/grafana/loki-stack).

To upgrade the stack to a newer version, run the following command, replacing the `< >` placeholders with their corresponding information:

```console
helm upgrade loki grafana/loki-stack \
  --version <KUBE_Loki_STACK_NEW_VERSION> \
  --namespace loki-stack \
  --values <YOUR_HELM_VALUES_FILE>
```

See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation.

### Uninstalling

To uninstall Loki, you need to have Helm 3 installed. Once installed, run the following `uninstall` command:

```bash
helm uninstall loki -n loki-stack
```

And then the following `delete` command:

```bash
kubectl delete ns loki-stack
```

### Additional Resources

* [Quick Start](https://grafana.com/docs/loki/latest/getting-started/)
* [Documentation](https://grafana.com/docs/)
