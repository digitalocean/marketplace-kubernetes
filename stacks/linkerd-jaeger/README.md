# Linkerd-jaeger

Linkerd docs
<br/>
<https://github.com/linkerd/linkerd2>

Distributed tracing with Linkerd 
<br/>
<https://linkerd.io/2/tasks/distributed-tracing/>

check linkerd pod running
<br/>
kubectl get pod -n linkerd

expose UI to localhost:8084
<br/>
kubectl -n linkerd port-forward linkerd-web-pod-name 8084:8084

inject linkerd to deployment in default namsespace
<br/>
kubectl -n default get deploy -o yaml | linkerd inject - | kubectl apply -f -

analyze in browser localhost:8084
<br/>

uninject linkerd 
<br/>
kubectl -n default deploy -o yaml | linkerd uninject - | kubectl apply -f -

uninstall linkerd
<br/>
linkerd install --ignore-cluster | kubectl delete -f -
