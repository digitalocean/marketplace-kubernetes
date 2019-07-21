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

## Get your gateway URL and password

```
kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode > password.txt

export OPENFAAS_URL=$(kubectl get svc -n openfaas gateway-external -o  jsonpath='{.status.loadBalancer.ingress[*].ip}'):8080

echo "Your gateway URL is: ${OPENFAAS_URL}"

cat password.txt | faas-cli login --username admin --password-stdin

faas-cli store deploy nodeinfo

faas-cli list -v

faas-cli describe nodeinfo
```