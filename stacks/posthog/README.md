# Getting started

### Minimum requirements

Please make sure that each node in the Kubernetes node pool has the following specifications - 

```
4 GB RAM, 2 vCPUs, 40GB Disk
```

Please use a minimum of 2 nodes in the deployment.

### Deploying and accessing PostHog 

After deploying the 1-click PostHog from the DigitalOcean marketplace, you will see a number of components deployed in the `posthog` namespace - 

1. PostHog Web - Deployment 
2. PostHog Worker - Deployment
2. PostHog Plugin - Deployment
3. Clickhouse - StatefulSet 
4. Redis - StatefulSet
5. Postgres - StatefulSet
6. Kafka - StatefulSet
6. ZooKeeper - StatefulSet


```
$ kubectl --namespace posthog get pods
NAME                                                  READY   STATUS    RESTARTS   AGE
chi-posthog-posthog-0-0-0                             1/1     Running   0          6d9h
clickhouse-operator-7c4c49c78c-4fzqq                  2/2     Running   0          6d9h
posthog-beat-7fd7bcf69f-9cfcx                         1/1     Running   2          6d9h
posthog-kube-state-metrics-5fc84b6c89-hz8vm           1/1     Running   0          6d9h
posthog-pgbouncer-65849845c-5cw9h                     1/1     Running   0          6d9h
posthog-pgbouncer-65849845c-dx4q8                     1/1     Running   0          6d9h
posthog-plugins-56b56f5f7-mtjb7                       1/1     Running   2          6d9h
posthog-plugins-56b56f5f7-njj2w                       1/1     Running   2          6d9h
posthog-posthog-kafka-0                               1/1     Running   0          6d9h
posthog-posthog-postgresql-0                          1/1     Running   0          6d9h
posthog-posthog-redis-master-0                        1/1     Running   0          6d9h
posthog-posthog-redis-slave-0                         1/1     Running   0          6d9h
posthog-posthog-redis-slave-1                         1/1     Running   1          6d9h
posthog-prometheus-alertmanager-5f4745cb4b-lfwc6      2/2     Running   0          6d9h
posthog-prometheus-server-b79f69579-cp2bn             2/2     Running   0          6d9h
posthog-prometheus-statsd-exporter-584dc79887-tlnsl   1/1     Running   0          6d9h
posthog-web-5d5dccdfcd-tpbwb                          1/1     Running   0          6d9h
posthog-worker-d4d6bb46c-c668t                        1/1     Running   0          6d9h
posthog-worker-d4d6bb46c-r7m6t                        1/1     Running   0          6d9h
posthog-zookeeper-0                                   1/1     Running   0          6d9h
```

Next, port-forward from local to the posthog-posthog-web instance, to access the PostHog UI - 

```
kubectl port-forward --namespace posthog posthog-web-5d5dccdfcd-tpbwb 8000:8000
```

You should now be able to navigate to PostHog at http://localhost:8000/ 

You are now all set up to start trying out PostHog!
