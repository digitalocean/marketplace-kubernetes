# Description

[OpenFaaS](https://docs.openfaas.com/) makes it easy for developers to deploy event-driven functions and microservices to Kubernetes without repetitive, boiler-plate coding. Package your code or an existing binary in a Docker image to get a highly scalable endpoint with auto-scaling and metrics. Your workloads can be accessed through the OpenFaaS gateway or triggered by a number of event sources such as Kafka, RabbitMQ, Redis and Cron.

The DigitalOcean 1-click application installs the [Helm 3](https://helm.sh/docs/intro/install/) version of OpenFaaS alongside with [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) and [Cert-Manager](https://cert-manager.io/docs/).

Note: This stack requires a minimum configuration of 2 Nodes at the $10/month plan (2GB memory / 1 vCPU).

## Software included

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

As you get started with Kubernetes on DigitalOcean be sure to check out how to connect to your cluster using `kubectl` and `doctl`:
<https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/>

Additional instructions for configuring the [DigitalOcean Kubernetes](https://cloud.digitalocean.com/kubernetes/clusters/):

- [How to Set Up a DigitalOcean Managed Kubernetes Cluster (DOKS)](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/01-setup-DOKS#how-to-set-up-a-digitalocean-managed-kubernetes-cluster-doks)
- [How to Set up DigitalOcean Container Registry](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/02-setup-DOCR#how-to-set-up-digitalocean-container-registry)

### How to confirm that OpenFaaS is running

First, check if the Helm installation was successful, by running below command:

```console
helm ls -n openfaas
```

The output looks similar to (notice that the `STATUS` column value is `deployed`):

```text
NAME          NAMESPACE REVISION UPDATED                              STATUS   CHART                APP VERSION
cert-manager  openfaas  1        2022-03-02 10:36:02.45917 +0200 EET  deployed cert-manager-v1.6.1  v1.6.1
ingress-nginx openfaas  1        2022-03-02 10:29:43.919627 +0200 EET deployed ingress-nginx-4.0.13 1.1.0
openfaas      openfaas  1        2022-03-02 10:40:25.804165 +0200 EET deployed openfaas-10.0.13
```

Next, verify if the OpenFaaS Pods are up and running:

```console
kubectl get pods -n openfaas -l 'app in (gateway, nats, queue-worker)'
```

The output looks similar to (all Pods should be in a `READY` state, and `STATUS` should be `Running`):

```text
NAME                            READY   STATUS    RESTARTS   AGE
gateway-7d56f99c9c-xz2hh        2/2     Running   0          87m
nats-697d4bd9fd-4pr5g           1/1     Running   0          87m
queue-worker-7579944c7d-vtf48   1/1     Running   0          87m
```

Finally, OpenFaaS should now be successfully installed and running.

### Tweaking Helm Values

The OpenFaaS provides some custom values to start with. You can always inspect all the available options, as well as the default values for the Ambassador Ingress Helm chart by running below command:

```console
helm show values openfaas/openfaas --version 10.0.13
```

After tweaking the Helm values file (`values.yml`) according to your needs, you can always apply the changes via `helm upgrade` command, as shown below:

```console
helm upgrade openfaas openfaas/openfaas --version 10.0.13 \
  --namespace openfaas \
  --values values.yml
```

### Configuring TLS with nginx-ingress and cert-manager

The following steps will guide you how to expose your local OpenFaaS functions to the Internet for development & testing.

Inspect the external IP address of your Nginx Ingress Controller Load Balancer by running below command:

```console
kubectl get svc -n openfaas -l app.kubernetes.io/name=ingress-nginx
```

The output looks similar to (look for the `EXTERNAL-IP` column, containing a valid IP address):

```text
NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.245.110.213   157.230.202.3   80:32375/TCP,443:30249/TCP   88m
ingress-nginx-controller-admission   ClusterIP      10.245.133.50    <none>          443/TCP                      88m
```

Now create a DNS A record in your DNS manager pointing to your IngressController's public IP.

Before creating the ssl certificate an issuer needs to be created. For convenience we will create an Issuer using Let's Encrypt production API. Replace `<your-email-here>` with the contact email that will be shown with the TLS certificate.

```text
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

```console
kubectl apply -f letsencrypt-issuer.yaml
```

Add TSL to OpenFaaS by creating a custom helm values file. Replace `<your-domain-here>` with the domain that will be used.

```text
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

```console
helm upgrade openfaas \
    --namespace openfaas \
    --reuse-values \
    --values tls.yaml \
    openfaas/openfaas
```

A certificate will be created automatically through cert-manager. You can validate that certificate has been obtained successfully using:

```console
kubectl describe certificate \
  -n openfaas \
  openfaas-crt
```

Finally, you can access the OpenFaaS UI and you can start creating functions.

**Note:**
Retrieve the OpenFaaS credentials running

```console
kubectl -n openfaas get secret basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode

```

### Upgrading the OpenFaaS Chart

You can check what versions are available to upgrade, by navigating to the [OpenFaaS](https://artifacthub.io/packages/helm/openfaas/openfaas/) official helm charts from Artifacthub.

Then, to upgrade the stack to a newer version, please run the following command (make sure to replace the `<>` placeholders first):

```console
helm upgrade openfaas openfaas/openfaas \
  --version <INGRESS_AMBASSADOR_STACK_NEW_VERSION> \
  --namespace openfaas \
  --values <YOUR_HELM_VALUES_FILE>
```

See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation.

### Uninstalling

To uninstall OpenFaaS, you'll need to have Helm 3 installed. Once install, run the following:

```console
helm uninstall openfaas --namespace openfaas

helm uninstall ingress-nginx --namespace openfaas

helm uninstall cert-manager --namespace openfaas
```

followed by:

```console
kubectl delete namespace openfaas openfaas-fn
```

### Additional Resources

To further enrich your experience, you can also visit the official Ambassador Edge Stack documentation sites:

- [Documentation](https://www.getambassador.io/docs/latest/)
- [Kubernetes Glossary](https://www.getambassador.io/learn/kubernetes-glossary/)
- [Ambassador Community Resources](https://www.getambassador.io/community/)
- [Community Slack Channel](https://join.slack.com/t/datawire-oss/shared_invite/zt-8rbpcp4x-vqcfpwmJYxcCVSL1CPxGLw)
- [FAQ](https://www.getambassador.io/docs/latest/about/faq/)
