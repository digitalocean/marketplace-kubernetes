Create namespace grafana -
kubectl create namespace grafana

Use the following command at this directory level to render yaml files -
helm template \
  --values ./values/values.yaml \
  --output-dir ./manifests \
    ./charts/grafana —name grafana --namespace grafana

Go to manifests/grafana/template - 
kubectl apply -f .