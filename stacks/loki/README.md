# Description

[Loki](https://grafana.com/oss/loki/) is a horizontally scalable, highly available, multi-tenant log aggregation system inspired by [Prometheus](https://prometheus.io/). It is designed to be very cost effective and easy to operate. It does not index the contents of the logs, but rather a set of labels for each log stream.

Compared to other log aggregation systems, Loki:

* Does not do full text indexing on logs. By storing compressed, unstructured logs and only indexing metadata, Loki is simpler to operate and cheaper to run.
* Indexes and groups log streams using the same labels you’re already using with Prometheus, enabling you to seamlessly switch between metrics and logs using the same labels that you’re already using with Prometheus.
* Is an especially good fit for storing [Kubernetes](https://kubernetes.io/) Pod logs. Metadata such as Pod labels is automatically scraped and indexed.
* Has native support in Grafana (needs Grafana v6.0).

A Loki-based logging stack consists of 3 components:

* promtail is the agent, responsible for gathering logs and sending them to Loki.
* loki is the main server, responsible for storing logs and processing queries.
* Grafana for querying and displaying the logs.

Loki is like Prometheus, but for logs: we prefer a multidimensional label-based approach to indexing, and want a single-binary, easy to operate system with no dependencies. Loki differs from Prometheus by focussing on logs instead of metrics, and delivering logs via push, instead of pull.

**Notes:**

* This stack requires a minimum configuration of 2 Nodes at the $10/month plan (2GB memory / 1 vCPU).
* The Loki stack 1-Click App also includes a $1/month block storage for both Grafana and Loki time series database (two PVs of 5GB each, to start with).

## Software included

| Package               | Application Version   | Helm Chart Version |License                                                                                    |
| ---| ---- | ---- | ------------- |
| Loki Stack | 2.1.0 | [2.5.1](https://artifacthub.io/packages/helm/grafana/loki-stack/2.5.1) | [Apache 2.0](https://github.com/grafana/loki/blob/main/LICENSE) |

## Getting Started

### Getting Started with DigitalOcean Kubernetes

As you get started with Kubernetes on DigitalOcean be sure to check out how to connect to your cluster using `kubectl` and `doctl`:
<https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/>

Additional instructions for configuring the [DigitalOcean Kubernetes](https://cloud.digitalocean.com/kubernetes/clusters/):

* [How to Set Up a DigitalOcean Managed Kubernetes Cluster (DOKS)](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/01-setup-DOKS#how-to-set-up-a-digitalocean-managed-kubernetes-cluster-doks)
* [How to Set up DigitalOcean Container Registry](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/02-setup-DOCR#how-to-set-up-digitalocean-container-registry)

### How to confirm that Loki stack is running

First, check if the Helm installation was successful, by running below command:

```bash
helm ls -n loki-stack
```

The output looks similar to (notice that the `STATUS` column value is `deployed`):

```text
NAME NAMESPACE  REVISION UPDATED                              STATUS   CHART            APP VERSION
loki loki-stack 1        2022-02-16 14:47:29.497728 +0200 EET deployed loki-stack-2.5.1 v2.1.0
```

Next, verify if the Loki Pods are up and running:

```console
kubectl get pods -n loki-stack
```

The output looks similar to (all Pods should be in a `READY` state, and `STATUS` should be `Running`):

```text
NAME                           READY   STATUS    RESTARTS   AGE
loki-0                         1/1     Running   0          20h
loki-grafana-575479b9f-ggxwn   1/1     Running   0          20h
loki-promtail-kvjxr            1/1     Running   0          20h
loki-promtail-nc7zg            1/1     Running   0          20h
loki-promtail-strvq            1/1     Running   0          20h
```

### Accessing Loki Grafana Web Panel

To get the admin password for the Grafana, run the following command:

```console
kubectl get secret --namespace loki-stack loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

You can access Loki Grafana web console by port forwarding the `loki-grafana` service:

```console
kubectl --namespace loki-stack port-forward svc/loki-grafana 8080:80
```

Navigate to <http://localhost:8080/> and login with admin and the password output above. Then follow the instructions for adding the loki datasource, using the URL <http://loki:3100/>.

Please refer to the [Loki](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/05-setup-loki-stack/README.md) tutorial, for more details about deployment status and functionality.

### Tweaking Helm Values

The `loki-stack` provides some custom values to start with. Please have a look at the [values](./values.yml) file from the main GitHub repository (explanations are provided inside, where necessary).

You can always inspect all the available options, as well as the default values for the `loki-stack` Helm chart by running below command:

```console
helm show values grafana/loki-stack --version 2.5.1
```

After tweaking the Helm values file (`values.yml`) according to your needs, you can always apply the changes via `helm upgrade` command, as shown below:

```console
helm upgrade loki grafana/loki-stack --version 2.5.1 \
  --namespace loki-stack \
  --values values.yml
```

### Upgrading the Loki Stack Chart

You can check what versions are available to upgrade, by navigating to the [loki-stack](https://github.com/grafana/loki/releases) official releases page from GitHub. Alternatively, you can also use [ArtifactHUB](https://artifacthub.io/packages/helm/grafana/loki-stack), which provides a more rich and user friendly interface.

Then, to upgrade the stack to a newer version, please run the following command (make sure to replace the `<>` placeholders first):

```console
helm upgrade loki grafana/loki-stack \
  --version <KUBE_Loki_STACK_NEW_VERSION> \
  --namespace loki-stack \
  --values <YOUR_HELM_VALUES_FILE>
```

See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation.

### Uninstalling

To uninstall Loki, you'll need to have Helm 3 installed. Once install, run the following:

```bash
helm uninstall loki -n loki-stack
```

followed by:

```bash
kubectl delete ns loki-stack
```

### Additional Resources

To further enrich your experience, you can also visit the official Ambassador Edge Stack documentation sites:

* [Quick Start](https://grafana.com/docs/loki/latest/getting-started/)
* [Documentation](https://grafana.com/docs/)
