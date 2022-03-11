# Description

[OpenFaaS](https://docs.openfaas.com/) is an open-source project that enables users to deploy applications to Kubernetes in a serverless style. It can package and deploy any micro-service, API, binary, or function. Once you deploy [a workload](https://docs.openfaas.com/reference/workloads/) via the [OpenFaaS CLI](https://docs.openfaas.com/cli/install/), it can auto-scale your code in response to user  demand based on API or UI metrics.

OpenFaaS comes with built-in auto-scaling, [detailed metrics](https://docs.openfaas.com/architecture/metrics/), and [queue-processing](https://docs.openfaas.com/reference/async/). It also provides pre-made functions and a series of templates for languages such as C#, Java, Go, Ruby, and PHP,

You can access your workloads through the OpenFaaS gateway and trigger them with [event sources](https://docs.openfaas.com/reference/triggers/) such as Kafka, RabbitMQ, Redis and Cron.

OpenFaaS is built around extendable open interfaces, which allow you to [enable TLS](https://docs.openfaas.com/reference/ssl/kubernetes-with-cert-manager/) and set up [custom domains](https://docs.openfaas.com/reference/ssl/kubernetes-with-cert-manager/#20-ssl-and-custom-domains-for-functions), CI/CD, OAuth2, multi-user support, etc.

You can find out more about OpenFaaS at [the official website](https://www.openfaas.com/) or take the [free online workshop](https://github.com/openfaas/workshop/).

**Note:** This stack requires a minimum configuration of 2 Nodes at the $10/month plan (2GB memory / 1 vCPU).

## Software Included

| Package               | Application Version   |License                                                                                    |
| ---| ---- | ------------- |
| Prometheus | [2.11.0](https://github.com/prometheus/prometheus/releases/tag/v2.11.0) | [Apache 2.0](https://github.com/prometheus/prometheus/blob/master/LICENSE) |
| Alertmanager | [0.18.0](https://github.com/prometheus/alertmanager/releases/tag/v0.18.0) | [Apache 2.0](https://github.com/prometheus/prometheus/blob/master/LICENSE) |
| NATS Streaming | [0.22.0](https://github.com/nats-io/nats-streaming-server/releases/tag/v0.22.0) | [Apache 2.0](https://github.com/nats-io/nats-streaming-server/blob/master/LICENSE) |
| faas-netes | [0.14.2](https://github.com/openfaas/faas-netes/releases/tag/0.14.2) | [MIT](https://github.com/openfaas/faas-netes/blob/master/LICENSE) |
| faas | [0.21.3](https://github.com/openfaas/faas/releases/tag/0.21.3) | [MIT](https://github.com/openfaas/faas/blob/master/LICENSE) |
| nats-queue-worker | [0.12.2](https://github.com/openfaas/nats-queue-worker/releases/tag/0.12.2) | [MIT](https://github.com/openfaas/nats-queue-worker/blob/master/LICENSE) |

## Getting Started

### How to Connect to Your Cluster

You can connect to your DigitalOcean Kubernetes cluster by following our [how-to guide](https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/).

For additional instructions on configuring a [DigitalOcean Kubernetes](https://cloud.digitalocean.com/kubernetes/clusters/) cluster, see the following guides:

- [How to Set Up a DigitalOcean Managed Kubernetes Cluster (DOKS)](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/01-setup-DOKS#how-to-set-up-a-digitalocean-managed-kubernetes-cluster-doks)
- [How to Set up DigitalOcean Container Registry](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/02-setup-DOCR#how-to-set-up-digitalocean-container-registry)

### How to Confirm that OpenFaaS is Running

First, verify that the Helm installation was successful by running following command:

```console
helm ls -n openfaas
```

If the installation was successful, the `STATUS` column value in the output reads `deployed`:

```text
NAME          NAMESPACE REVISION UPDATED                              STATUS   CHART                APP VERSION
openfaas      openfaas  1        2022-03-02 10:40:25.804165 +0200 EET deployed openfaas-10.0.13
```

Next, verify that the OpenFaaS pods are up and running with the following command:

```console
kubectl get pods -n openfaas -l 'app in (gateway, nats, queue-worker)'
```

If they're running, all pods listed in the output are in a `READY` state and the `STATUS` for each reads `Running`:

```text
NAME                            READY   STATUS    RESTARTS   AGE
gateway-7d56f99c9c-xz2hh        2/2     Running   0          87m
nats-697d4bd9fd-4pr5g           1/1     Running   0          87m
queue-worker-7579944c7d-vtf48   1/1     Running   0          87m
```

OpenFaaS is now successfully installed and running.

### Tweaking Helm Values

OpenFaaS has custom default Helm values. To inspect its current values, run the following command:

```console
helm show values openfaas/openfaas --version 10.0.13
```

To change these values, open the Helm values file `values.yml`, change whatever values you want, save and exit the file, and apply the changes by running `helm upgrade` command:

```console
helm upgrade openfaas openfaas/openfaas --version 10.0.13 \
  --namespace openfaas \
  --values values.yml
```

### Configuring TLS with nginx-ingress and cert-manager

The following steps will guide you how to expose your local OpenFaaS functions to the Internet for development & testing.

To expose your local OpenFaaS functions to the internet, you need to install the NGINX Ingress Controller and Cert-Manager 1-Click Apps via the [Digital Ocean Marketplace](https://marketplace.digitalocean.com/category/kubernetes).

Then, inspect the external IP address of your NGINX Ingress Controller Load Balancer by running following command:

```console
kubectl get svc -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

If installed correctly, the output has the `EXTERNAL-IP` column, containing a valid IP address:

```text
NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.245.110.213   157.230.202.3   80:32375/TCP,443:30249/TCP   88m
ingress-nginx-controller-admission   ClusterIP      10.245.133.50    <none>          443/TCP                      88m
```

Create a DNS A record pointing to your IngressController's public IP in your DNS manager. For specific instructions on how to do this, see the official [OpenFaaS documentation](https://docs.openfaas.com/reference/ssl/kubernetes-with-cert-manager/#create-a-dns-record).

Then, create an issuer. For convenience, this tutorial uses the Let's Encrypt production API. Create the following YAML file and replace `<your-email-here>` with the contact email that you want the TLS certificate to show.

```yaml
# letsencrypt-issuer.yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-prod
  namespace: openfaas
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email:  <your-email-here>
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource used to store the account's private key.
      name: prod-issuer-account-key
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
    - http01:
        ingress:
          class: nginx
```

Apply via `kubectl`:

```console
kubectl apply -f letsencrypt-issuer.yaml
```

To add TLS to OpenFaaS, create the following custom helm value file and replace `<your-domain-here>` with your desired domain name:

```yaml
# tls.yaml
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/issuer: letsencrypt-prod
  tls:
    - hosts:
        - <your-domain-here>
      secretName: openfaas-crt
  hosts:
    - host: <your-domain-here>
      serviceName: gateway
      servicePort: 8080
      path: /
```

Upgrade via `helm`:

```console
helm upgrade openfaas \
    --namespace openfaas \
    --reuse-values \
    --values tls.yaml \
    openfaas/openfaas
```

This automatically creates a certificate through cert-manager. You can then verify that you've successfully obtained the certificate by running the following command:

```console
kubectl get certificate \
  -n openfaas \
  openfaas-crt
```

If successful, the output's `READY` column reads `True`:

```bash
NAME           READY   SECRET         AGE
openfaas-crt   True    openfaas-crt   152m
```

Now, you can access the OpenFaaS UI and start creating functions.

**Note:**
To retrieve the OpenFaaS credentials, run the following command:

```console
kubectl -n openfaas get secret basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode

```

### Log into OpenFaaS using faas-cli

You can install the CLI with a curl utility script, with brew, or by downloading the binary from the releases page. Once installed, you will get the faas-cli command and faas alias. For more details, see the official [installation guide](https://docs.openfaas.com/cli/install/).

First, extract the password:

```console
kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode > password.txt
```

Next, authenticate to the `faas-cli`, replacing `<your-domain-here>` with your desired domain name:

```console
export OPENFAAS_URL=https://<your-domain-here>

cat password.txt | faas-cli login --username admin --password-stdin --gateway https://<your-domain-here>
```

Then, verify it is operational by deploying a function:

```console
faas-cli store list

# Find one you like

faas-cli store deploy nodeinfo

# List your functions

faas-cli list --verbose

# Check when the function is ready

faas-cli describe nodeinfo

Name:                nodeinfo
Status:              Ready

# Invoke the function using the URL given above, or via `faas-cli invoke`

echo | faas-cli invoke nodeinfo
echo -n "verbose" | faas-cli invoke nodeinfo
```

### Create your first Python function with OpenFaaS

First, create a working folder for your first function:

```bash
mkdir -p ~/functions && cd ~/functions
```

Then, scaffold a new Python function with the CLI:

```bash
faas-cli new --lang python3 hello-python
```

The output looks similar to the following:

```text
2022/03/03 15:18:07 No templates found in current directory.
2022/03/03 15:18:07 Attempting to expand templates from https://github.com/openfaas/templates.git
2022/03/03 15:18:09 Fetched 16 template(s) : [csharp dockerfile go java11 java11-vert-x node node12 node12-debian node14 node16 node17 php7 python python3 python3-debian ruby] from https://github.com/openfaas/templates.git
Folder: hello-python created.
```

All of your functions should be specified in a YAML file. This format informs the CLI what to build and deploy onto your OpenFaaS cluster.

Check out the YAML file `hello-python.yml`:

- gateway: Here, you can specify a remote gateway if needed, what the programming language is, and where our handler is located within the filesystem.

- functions - Here, you can define the functions in our stack.

- lang: python - Even though Docker is used behind the scenes to package your function, you do not have to write your own Dockerfile here.

- handler - This is the folder/path to your `handler.py` file and other source code.

- image - This is the Docker image name. If you are going to push to the Docker Hub, change the prefix from `hello-python` to include your Docker Hub account, for example, `alexellis/hello-python`.

Next, build the function and push the function image to a registry or the [Docker Hub](https://hub.docker.com/).

Upload the function to a remote registry:

```bash
faas-cli build -f ./hello-python.yml
```

Deploy the function:

```bash
faas-cli deploy -f ./hello-python.yml
```

The output looks similar to:

```bash
Deploying: hello-python.

Deployed. 202 Accepted.
URL: https://<your-domain>/function/hello-python
```

Finally, test the function using `faas-cli`:

```bash
echo "Hello" | faas-cli invoke hello-python
```

The response from the function is `Hello`.

For different OpenFaaS tutorrials, please see the list of [featured OpenFaaS tutorials](https://docs.openfaas.com/tutorials/featured/).

### Upgrading the OpenFaaS Chart

You can check what versions are available to upgrade by navigating to the [OpenFaaS](https://artifacthub.io/packages/helm/openfaas/openfaas/) official helm charts from Artifacthub.

To upgrade the stack to a newer version, run the following command, replacing the `< >` placeholders with their corresponding information:

```console
helm upgrade openfaas openfaas/openfaas \
  --version <OPENFAAS_STACK_NEW_VERSION> \
  --namespace openfaas \
  --values <YOUR_HELM_VALUES_FILE>
```

See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation.

### Uninstalling

To uninstall OpenFaaS, you need to have Helm 3 installed. Once installed, run the following `uninstall` command:

```console
helm uninstall openfaas --namespace openfaas
```

And then the following `delete` command:

```console
kubectl delete namespace openfaas openfaas-fn
```

### Additional Resources

- [Official OpenFaaS Documentation](https://docs.openfaas.com/community/)
