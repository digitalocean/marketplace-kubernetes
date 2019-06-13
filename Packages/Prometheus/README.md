Create namespace prometheus -
kubectl create namespace prometheus 

Use the following command at this directory level to render yaml files -
helm template \
  --values ./values/values.yaml \
  --output-dir ./manifests \
    ./charts/prometheus —name prometheus --namespace prometheus

Go to manifests/prometheus/template - 
kubectl apply -f .
