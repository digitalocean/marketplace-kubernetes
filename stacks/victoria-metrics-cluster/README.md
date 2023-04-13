## Application summary

VictoriaMetrics Cluster is a fast and scalable open source time series database and monitoring solution.

## Description

VictoriaMetrics Cluster is a free, [open source time series database](https://en.wikipedia.org/wiki/Time_series_database) (TSDB) and monitoring solution,
designed to collect, store and process real-time metrics.

It supports the [Prometheus](https://en.wikipedia.org/wiki/Prometheus_(software)) pull model and various push protocols ([Graphite](https://en.wikipedia.org/wiki/Graphite_(software)), [InfluxDB](https://en.wikipedia.org/wiki/InfluxDB), OpenTSDB) 
for data ingestion. It is optimized for storage with high-latency IO, low IOPS and time series with [high churn rate](https://docs.victoriametrics.com/FAQ.html#what-is-high-churn-rate).

For reading the data and evaluating alerting rules, VictoriaMetrics supports the PromQL, MetricsQL and Graphite query languages.
VictoriaMetrics Cluster is fully autonomous and can be used as a long-term storage for time series. It supports all features of VictoriaMetrics Single;
capacity scales horizontally, multiple independent namespaces for time series data  (aka multi-tenancy) and replication.

This stack deploys the VictoriaMetrics Kubernetes operator and manages
VictoriaMetrics Cluster using native Kubernetes Custom Resources. This removes the
complexity of operating VictoriaMetrics Cluster and simplifies working with it.

## Base Requirements

The VictoriaMetrics Cluster database requires at least two replicas to function
effectively. The operator will make it's best effort to spread all components
across nodes to ensure availability.

[VictoriaMetrics Cluster](https://docs.victoriametrics.com/Cluster-VictoriaMetrics.html)  =  Highly available horizontally scalable monitoring solution optimized for high performance.  Supports multiple independent namespaces (aka multi-tenancy) and replication. Cluster version is preferable for large or rapidly growing environments.

[vmgent](https://docs.victoriametrics.com/vmagent.html) = Lightweight agent that helps users collect metrics from various sources and store them in VictoriaMetrics or any other Prometheus-compatible storage systems.

[vmperator](https://github.com/VictoriaMetrics/operator) = Kubernetes operator for Victoria Metrics = is a tool that creates/configures/manages VictoriaMetrics Cluster's atop Kubernetes.

**Software Included:**

| Package  | Version | License |
| ------------- | ------------- | ------------- |
| VictoriaMetrics Cluster  | [1.87.1](https://docs.victoriametrics.com/CHANGELOG.html#v1871)  | Apache 2.0  |
| vmagent  | [1.87.1](https://docs.victoriametrics.com/CHANGELOG.html#v1871)  | Apache 2.0  |
| vmoperator  | [0.30.4](https://github.com/VictoriaMetrics/operator/releases/tag/v0.30.4)  | Apache 2.0  |

## Getting started after deploying VictoriaMetrics Cluster

After you have downloaded your kube config file, and are able to successfully connect to your Kubernetes cluster (see https://cloud.digitalocean.com/kubernetes/clusters/ if you haven’t connected to your cluster) follow the instructions below to start using VictoriaMetrics Cluster.

Verify that VictoriaMetrics Cluster and vmagent pods are up and running by executing the following commands:

```bash
kubectl get vmclusters
```

```bash
kubectl get vmagents
```

To remove VictoriaMetrics Cluster and vmagent from your Kubernetes Cluster run the following commands:

```bash
kubectl delete vmclusters --all-namespaces --all
```

```bash
kubectl delete vmagents --all-namespaces --all
```

## Access the Database from outside the Kubernetes cluster

Run the following command to make `vmselect`'s port accessible from the local machine:

```bash
kubectl port-forward svc/vmselect-vmcluster 8481:8481
```

Run the following command to query and retrieve a result from `vmselect`:

```bash
curl -sg 'http://127.0.0.1:8481/select/0/prometheus/api/v1/query_range?query=vm_app_uptime_seconds' | jq
```

VictoriaMetrics provides a [User Interface  (UI)](https://docs.victoriametrics.com/Single-server-VictoriaMetrics.html#vmui) for query troubleshooting and exploration. The UI is available at `http://vmselect:8481/select/0/vmui/`. The UI lets users explore query results via graphs and tables.

To check it, run the following command to make `vmselect`'s port accessible from the local machine:

```bash
kubectl port-forward svc/vmselect-vmcluster 8481:8481
```

Then open in browser `http://127.0.0.1:8481/select/0/vmui/` , enter `vm_app_uptime_seconds` to the Query Field and Execute Query.

## For further documentation visit:

- [https://docs.victoriametrics.com/Cluster-VictoriaMetrics.html#cluster-setup](https://docs.victoriametrics.com/Cluster-VictoriaMetrics.html#cluster-setup)
- [https://docs.victoriametrics.com/guides](https://docs.victoriametrics.com/guides)
- [https://github.com/VictoriaMetrics/helm-charts](https://github.com/VictoriaMetrics/helm-charts)
- [https://docs.victoriametrics.com/Articles.html](https://docs.victoriametrics.com/Articles.html)