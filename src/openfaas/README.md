## Generate the OpenFaaS helm Chart

```
export APP_NAME="openfaas"
export HELM_CHART_NAME="openfaas"
export HELM_CHART_VERSION="4.4.0"
export HELM_REPO="openfaas/"

helm repo add openfaas https://openfaas.github.io/faas-netes/

helm repo update

mkdir src/$APP_NAME
cd src/$APP_NAME
helm fetch --version $HELM_CHART_VERSION --untar $HELM_REPO$HELM_CHART_NAME
mv $APP_NAME $HELM_CHART_VERSION
```

Enable the `LoadBalancer` in `values.yaml`:

```
sed -ie s/serviceType:\ NodePort/serviceType:\ LoadBalancer/ ${HELM_CHART_VERSION}/values.yaml
```

```
rm -rf ../stacks/openfaas
cd utils
STACK_NAME=$APP_NAME ./generate-stack.sh

cd ..
./stacks/$APP_NAME/render.sh
```
