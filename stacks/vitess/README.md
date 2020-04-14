# Description 
-------------
Vitess is a cloud native sharded database system. It allows you to scale out
your database much like you would scale out your stateless workloads. 

http://vitess.io

This stack deploys the Vitess Kubernetes Operator which deploys and manages
Vitess clusters using native Kubernetes Custom Resources. This removes the
complexity of operating Vitess clusters and lets you deploy with the same. To
effectively deploy this stack you should have a minimum of 3 nodes in your
cluster. 

## Base Requirements
The example database requires four persistent volume claims ( 3 for the
lockserver, and 1 for the database ). It also requires three nodes to function
effectively. The operator will make its best effort to spread all components
across nodes to ensure availability. 

# Getting Started 

### Getting Started with DigitalOcean Kubernetes
As you get started with Kubernetes on DigitalOcean be sure to check out how to connect to your cluster using `kubectl` and `doctl`:
https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/
 
Additional instructions are included in the DigitalOcean Kubernetes control panel:
https://cloud.digitalocean.com/kubernetes/clusters/ 

#### Quick Start
If you just want to give this app a quick spin without `doctl` give the following a try.

Assuming you have done the following:
1. Created a cluster in the DigitalOcean control panel (https://cloud.digitalocean.com/kubernetes/clusters/).
1. Downloaded the Kubernetes config file to ~/Downloads directory on your local machine. The config file will have a name like `monitoring-k8s-1-15-3-do-1-sfo-kubeconfig.yaml`.
1. Installed Kubernetes command line tool, `kubectl`, (https://kubernetes.io/docs/tasks/tools/install-kubectl/) on your local machine.

Copy the Kubernetes config file to the default directory `kubectl` looks in.
```
cp ~/.kube/config  ~/.kube/config.bkup
cp  ~/Downloads/monitoring-k8s-1-15-3-do-1-sfo-kubeconfig.yaml  ~/.kube/config
```
You should now be able to connect to your DigitalOcean Kubernetes Cluster and successfully run commands like:
```
kubectl get pods -A
```

# Getting Started with the Vitess Operator

After you have deployed this stack you will have the Vitess operator and an
example Database cluster. 

## Confirm Vitess is running
After you are able to successfully connect to your DigitalOcean Kubernetes
cluster you’ll be able to see vitess running in the `vitess` namespace by
issuing:

 ```
 kubectl get pods -A
 ``` 
 Confirm all `vitess` pods are in a “`Running`” state under the “`STATUS`” column:

``` yaml
NAMESPACE     NAME                                                         READY   STATUS    RESTARTS   AGE
vitess        pod/example-digitalocean1-vtctld-9724b1b1-5885c9c77f-tv7rf   1/1     Running   0          16m
vitess        pod/example-digitalocean1-vtgate-2f816ccf-78b576467c-7546b   1/1     Running   0          16m
vitess        pod/example-etcd-faf13de3-1                                  1/1     Running   0          16m
vitess        pod/example-etcd-faf13de3-2                                  1/1     Running   0          16m
vitess        pod/example-etcd-faf13de3-3                                  1/1     Running   0          16m
vitess        pod/example-vttablet-digitalocean1-0104432793-9039143c       3/3     Running   1          16m
vitess        pod/vitess-operator-7f885997cb-j9g5b                         1/1     Running   0          16m

```

## Accessing the Cluster
To log into the example database cluster, use the following commands:

### Access the Database from outside the Kubernetes Cluster
Use the following commands to port-forward to the vtgate service, his service will load balance connections to all vtgates:

``` sh
VTGATE=$(kubectl get service -l "planetscale.com/component=vtgate,planetscale.com/cluster=example" -o custom-columns=Name:.metadata.name | tail -n -1)
kubectl port-forward service/"${VTGATE}" 3306&
```

You can now access your Vitess cluster on the forwarded port with the standard
MySQL client: 

``` sh
mysql -h 127.0.0.1 -u admin -pscalewithvitess main 
```

### Access the Database from inside the Kubernetes Cluster
Inside the Kubernetes cluster, the vtgate service will be accessible on the
service DNS name. You can find all vtgate services using the following command:

``` sh
kubectl get service -l "planetscale.com/component=vtgate,planetscale.com/cluster=example"
```

The vtgate server exposes a MySQL-compatible server on port 3306. It also has a
gRPC server on port 15999.


# Customizing the Database

The default database deployed by this stack is an example database that is not
suitable for production workloads. You can customize the example database by
fetching the YAML manifest from this location

``` sh
https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/vitess/yaml/example-cluster.yaml
```

## Important Changes for Production Workloads
The Vitess documentation contains general recommendations for production workloads:

https://vitess.io/docs/user-guides/production-planning/


### Username and Password
The example manifest contains a Kubernetes secret named
`example-cluster-config`. That secret contains the username and password of the
default user. Change these values to a secure username and password.
See the Vitess documentation for how to configure users and passwords:

https://vitess.io/docs/user-guides/user-management/

### Number of Gateways
By default, this example creates only one vtgate pod. To ensure reliability,
increase the number of vtgate pods to two or more. To do so, change the value of
`replicas` in the `example-cluster.yaml` configuration file: 
 
``` yaml
spec:
  cells:
  - name: ...
    gateway:
      replicas: 1
```
