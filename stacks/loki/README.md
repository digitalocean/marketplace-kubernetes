## Description

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
* The Loki stack 1-Click App also includes a $1/month block storage for both Grafana and Prometheus time series database (two PVs of 5GB each, to start with).

## Software included

| Package               | Version                                        | License                                                                                    |
| --------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Loki | 2.4.1 | [Apache 2.0](https://github.com/grafana/loki/blob/main/LICENSE) |
| Promtail | 2.1.0 | [Apache 2.0](https://github.com/grafana/loki/blob/main/LICENSE) |

## Getting Started

### Getting Started with DigitalOcean Kubernetes

As you get started with Kubernetes on DigitalOcean be sure to check out how to connect to your cluster using `kubectl` and `doctl`:
<https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/>

Additional instructions for configuring the [DigitalOcean Kubernetes](https://cloud.digitalocean.com/kubernetes/clusters/):

- [How to Set Up a DigitalOcean Managed Kubernetes Cluster (DOKS)](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/01-setup-DOKS#how-to-set-up-a-digitalocean-managed-kubernetes-cluster-doks)
- [How to Set up DigitalOcean Container Registry](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/02-setup-DOCR#how-to-set-up-digitalocean-container-registry)

### Getting started after deploying Loki

Verify Loki was installed correctly by running this command:

```bash
helm ls -n monitoring
```

The output looks similar to (notice that the `STATUS` column value is `deployed`):

```text
NAME NAMESPACE  REVISION UPDATED                              STATUS   CHART            APP VERSION
loki monitoring 1        2022-02-16 14:47:29.497728 +0200 EET deployed loki-stack-2.5.1 v2.1.0
```

After you deploy the stack you will have the following deployed to your cluster in the monitoring namespace:

* Promtail: The agent that is used to collect the logs.
* Loki: The log-aggregation system and the queriers.
* Grafana: The UI using which you can now query your logs.

```bash
kubectl --namespace monitoring get pods
```

The output looks similar to the following:

```bash
NAME                           READY   STATUS    RESTARTS   AGE
loki-0                         1/1     Running   0          36m
loki-grafana-575479b9f-ggxwn   1/1     Running   0          36m
loki-promtail-kvjxr            1/1     Running   0          36m
loki-promtail-nc7zg            1/1     Running   0          36m
loki-promtail-strvq            1/1     Running   0          36m
```

### Uninstalling

To uninstall Loki, you'll need to have Helm 3 installed. Once install, run the following:

```bash
helm uninstall loki -n monitoring
```

followed by:

```bash
kubectl delete ns monitoring
```

### Additional Resources

* [Quick Start](https://grafana.com/docs/loki/latest/getting-started/)
* [Documentation](https://grafana.com/docs/)
