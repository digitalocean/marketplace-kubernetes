# Getting Started with the Vitess Operator

After you have deployed this stack you will have the Vitess operator and an
example Database cluster. 

## Base Requirements
The example database requires four persistent volume claims ( 3 for the
lockserver, and 1 for the database ). It also requires three nodes to function
effectively. The operator will make its best effort to spread all components
across nodes to ensure availability. 

## Accessing the Cluster
To log into this cluster you can use the following commands


### Access the Database from outside the Kubernetes cluster
You can access the database outside the kubernetes cluster by port-forwarding to
the vtgate service. This service will load balance connection to all vtgates.

``` sh
VTGATE=$(kubectl get service -l "planetscale.com/component=vtgate,planetscale.com/cluster=example" -o custom-columns=Name:.metadata.name | tail -n -1)
kubectl port-forward service/"${VTGATE}" 3306&
```

you will then be able to access your vitess cluster on the forwarded port with
the standard mysql client 

``` sh
mysql -h 127.0.0.1 -u admin -pscalewithvitess main 
```

### Access the Database from inside the Kubernetes cluster
Inside the kubernetes cluster the vtgate service will be accessable on the
service DNS name. You can find all vtgate services by running 

``` sh
kubectl get service -l "planetscale.com/component=vtgate,planetscale.com/cluster=example"
```

Vtgate exposes a mysql compatible server on port 3306. It also has a gRPC server
on port 15999


# Customizing the Database
The default database deployed by this stack is an example database that is not
suitable for production workloads. You can customize the example database by
fetching the YAML manifest from here 

``` sh
https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/vitess/yaml/example-cluster.yaml
```

## Important Changes for Production workloads
General recommendations for production workloads can be found on the main Vitess
documentation site 

https://vitess.io/docs/user-guides/production-planning/


### Username and Password
In the example manifest there is a kubernetes secret named
`example-cluster-config`. That secret contains the username as password of the
default user. This should be changed to a secure username and password.
Reference the vitess documentation on how to configure users and passwords

https://vitess.io/docs/user-guides/user-management/

### Number of Gateways
By default only one vtgate pod is created. To ensure reliability this should be
increased to at least two. This setting is found here 

``` yaml
spec:
  cells:
  - name: ...
    gateway:
      replicas: 1
```
