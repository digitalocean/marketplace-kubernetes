# Summary 
[kube-state-metrics](https://github.com/kubernetes/kube-state-metrics) is a simple service that listens to the Kubernetes API server and generates metrics about the state of the objects.

# Description
[kube-state-metrics](https://github.com/kubernetes/kube-state-metrics) is focused on the  health of the various objects inside, such as deployments, nodes and pods.

kube-state-metrics exposes raw data unmodified from the Kubernetes API, this way users have all the data they require and perform heuristics as they see fit. The metrics are exported on the HTTP endpoint /metrics on the listening port (default 80). They are served as plaintext. They are designed to be consumed either by Prometheus itself or by a scraper that is compatible with scraping a Prometheus client endpoint. 

This DigitalOcean Marketplace 1-Click install kube-state-metrics onto your DigitalOcean Kubernetes cluster providing cluster metrics viewable in a browswer or consumable by Prometheus.

Thank you to all the contributors whose hard work make kube-state-metrics software valuable for users.


# Getting Started

### Getting Started with DigitalOcean Kubernetes
As you get started with Kubernetes on DigitalOcean be sure to check out how to [connect to your cluster](https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/) using `kubectl` and `doctl`:

Additional instructions are included in the [DigitalOcean Kubernetes control panel](https://cloud.digitalocean.com/kubernetes/clusters/)

#### Quick Start
If you just want to give this app a quick spin without `doctl` give the following a try.

Assuming you have done the following:
1. Created a cluster in the [DigitalOcean control panel](https://cloud.digitalocean.com/kubernetes/clusters/).
1. Downloaded the Kubernetes config file to ~/Downloads directory on your local machine. The config file will have a name like `monitoring-k8s-1-16-do-sfo-kubeconfig.yaml`.
1. Installed [Kubernetes command line tool](https://kubernetes.io/docs/tasks/tools/install-kubectl/), `kubectl`, on your local machine.

Copy the Kubernetes config file to the default directory `kubectl` looks in.
```
cp ~/.kube/config  ~/.kube/config.bkup
```
```
cp  ~/Downloads/monitoring-k8s-1-16-do-sfo-kubeconfig.yaml  ~/.kube/config
```
You should now be able to connect to your DigitalOcean Kubernetes Cluster and successfully run commands like:
```
kubectl get pods -A
```

### Confirm kube-state-metrics is running: 
After you are able to successfully connect to your DigitalOcean Kubernetes cluster you’ll be able to see kube-state-metrics running in the `kube-state-metrics` namespace by issuing:
 ```
 kubectl get pods -n kube-proxy
 ``` 
 Confirm all `kube-state-metrics` pods are in a “`Running`” state under the “`STATUS`” column:

```
NAMESPACE     NAME                                  READY    STATUS    RESTARTS    AGE
kube-system   kube-state-metrics-5684cbc89d-8899b    1/1     Running      0        22s
```

## Using kube-state-metrics

### DigitalOcean Advanced Metrics

With kube-state-metrics now running you can view DigitalOcean Kubernetes Advanced Metrics.
1. Go to https://cloud.digitalocean.com/kubernetes/clusters/
2. Select the cluster you installed kube-state-metrics onto.
3. Navigate to the `Insights` tab.

### Kubectl Proxy

Set `kubectl` to act as a [reverse proxy](https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/#using-kubectl-proxy). This mode handles locating the API server and authenticating.
```
kubectl proxy --port=8080
```
With the proxy running you can now curl the endpoint in another terminal window:
```
curl http://localhost:8080/metrics
```

### Go CLI

[Install the Go `kube-state-metrics` binary](https://github.com/kubernetes/kube-state-metrics#setup):
```
go get k8s.io/kube-state-metrics
```
Ensure your `$GOPATH` is set to something like:
```
export GOPATH="$GOPATH:$HOME/go"
```
Configure the `kube-state-metrics` Go binary to [use your cluster](https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/):
```
kube-state-metrics --port=8080 --telemetry-port=8081 --kubeconfig=/PATH/TO/KUBE/CONFIG --apiserver=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
```
In another terminal window curl the metrics endpoint:
```
curl localhost:8080/metrics
```