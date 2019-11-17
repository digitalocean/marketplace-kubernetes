# Getting started

### Minimum requirements

Please make sure that each node in the Kubernetes node pool has the following specifications - 

```
4 GB RAM, 2 vCPUs, 40GB Disk
```

Please use a minimum of 4 nodes in the deployment.

### Deploying and accessing the Jaeger UI

After deploying the 1-click Jaeger App from the DigitalOcean marketplace, you will see a number of components deployed in the `jaeger` namespace - 

1. Jaeger Agent - DaemonSet
2. Jaeger Collector - Deployment
3. Cassandra data - Deployment
4. Cassandra schema - Job
5. Jaeger Query - Deployment


```
$ kubectl --namespace jaeger get pods
NAME                                READY   STATUS      RESTARTS   AGE
jaeger-agent-4cd9v                  1/1     Running     0          3h
jaeger-agent-hmhbn                  1/1     Running     0          3h
jaeger-agent-mb2p4                  1/1     Running     0          3h
jaeger-agent-mtv5z                  1/1     Running     0          3h
jaeger-agent-s9hjd                  1/1     Running     0          3h
jaeger-agent-xm96d                  1/1     Running     0          3h
jaeger-cassandra-0                  1/1     Running     0          3h
jaeger-cassandra-1                  1/1     Running     0          3h
jaeger-cassandra-2                  1/1     Running     0          3h
jaeger-cassandra-schema-6mhgc       0/1     Completed   1          3h
jaeger-collector-54cbcf8c44-zftjh   1/1     Running     5          3h
jaeger-query-5dc755dc4f-8xskn       2/2     Running     5          3h

```

Next, port-forward from local to the Jaeger-Query instance, to access the Jaeger UI - 

```
kubectl port-forward --namespace jaeger jaeger-query-5dc755dc4f-8xskn 8080:16686
```

You should now be able to navigate to the Jaeger UI at http://localhost:8080/ 

You are now all set up to start tracing!
