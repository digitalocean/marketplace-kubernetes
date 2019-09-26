# Getting Started

After you deploy the stack you will have the following deployed to your cluster in the `loki` namespace:

1. Loki: The log-aggregation system and the queriers.
2. Promtail: The agent that is used to collect the logs.
3. Grafana: The UI using which you can now query your logs.

```
➜  ~ kubectl --namespace loki get po
NAME                            READY   STATUS    RESTARTS   AGE
loki-0                          1/1     Running   0          47h
loki-grafana-5dc6466b8d-2xkwf   1/1     Running   0          47h
loki-promtail-8ggnr             1/1     Running   0          47h
loki-promtail-fhxjw             1/1     Running   0          47h
loki-promtail-hpq7j             1/1     Running   0          47h
```

First grab the admin password for grafana: 
```
➜  ~ kubectl get secret --namespace loki loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
wjqmVpYcONHnpPttIavEMve0F24azXsOFk0LvHlP
```

Now port-forward to Grafana and login using the username `admin` and password you got above. To access Grafana, port-forward:
```
➜  ~ kc --namespace loki port-forward loki-grafana-5dc6466b8d-2xkwf 3000         
```
and visit http://localhost:3000/explore

In the explore UI, enter the query `{app="loki"}` or similar to get the logs. Happy querying!

