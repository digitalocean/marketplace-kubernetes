# Linkerd-jaeger

Linkerd docs
<br/>
<https://github.com/linkerd/linkerd2>

Distributed tracing with Linkerd 
<br/>
<https://linkerd.io/2/tasks/distributed-tracing/>

at linkerd-jaeger folder install linkerd with jaeger
<br/>
./deploy.sh

check linkerd pod running
<br/>
kubectl get pod -n linkerd

expose UI to localhost:8084
<br/>
kubectl -n linkerd port-forward linkerd-web-pod-name 8084:8084

at linkerd-jaeger folder deploy sample emojivoto app
<br />
kubectl apply -f yaml-files/emojivoto.yaml

check deployment
<br />
kubectl get pod -n emojivoto

inject linkerd to deployment in emojivoto namsespace
<br/>
kubectl -n emojivoto get deploy -o yaml | linkerd inject - | kubectl apply -f -

analyze in browser localhost:8084
<br/>

To enable tracing in emojivoto
<br/>
kubectl -n emojivoto set env --all deploy OC_AGENT_HOST=linkerd-collector.linkerd:55678

expose jaeger UI at localhost:16686
<br/>
kubectl -n linkerd port-forward svc/linkerd-jaeger 16686

search for any service in the dropdown and click Find Traces at localhost:16686.
<br/>

uninject linkerd 
<br/>
kubectl -n emojivoto get deploy -o yaml | linkerd uninject - | kubectl apply -f -

delete emojivoto deployment
<br/>
kubectl delete -f yaml-files/emojivoto.yaml

uninstall linkerd
<br/>
linkerd install --ignore-cluster | kubectl delete -f -
