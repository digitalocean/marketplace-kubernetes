# Getting started

After deploying the 1-click Jaeger App from the DigitalOcean marketplace, you will see a number of components deployed in the `jaeger` namespace - 

1. Jaeger Agent - DaemonSet
2. Jaeger Collector - Deployment
3. Cassandra data - Deployment
4. Cassandra schema - Job
5. Jaeger Query - Deployment


```
$ kubectl --namespace jaeger get pods
NAME                                    READY   STATUS      RESTARTS   AGE
jaeger-agent-27hgp                 1/1     Running     0          17h
jaeger-agent-f9m4c                 1/1     Running     0          17h
jaeger-agent-ktjn8                 1/1     Running     0          17h
jaeger-agent-n8lhk                 1/1     Running     0          17h
jaeger-agent-qc9h5                 1/1     Running     0          17h
jaeger-agent-v6xcx                 1/1     Running     0          17h
jaeger-cassandra-0                 1/1     Running     0          17h
jaeger-cassandra-1                 1/1     Running     0          17h
jaeger-cassandra-2                 1/1     Running     0          17h
jaeger-cassandra-schema-mfc5k      0/1     Completed   1          17h
jaeger-collector-8ccc9f46d-h6k7h   1/1     Running     5          17h
jaeger-query-dcdc6b565-792p6       2/2     Running     5          17h
```

Next, port-forward from local to the Jaeger-Query instance, to access the Jaeger UI - 

```
kubectl port-forward --namespace jaeger jaeger-query-dcdc6b565-792p6 8080:16686
```

You should now be able to navigate to the Jaeger UI at http://localhost:8080/ 

You are now all set up to start tracing!
