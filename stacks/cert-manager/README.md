# Description

[Cert-Manager](https://cert-manager.io/) is a very popular open source `certificate management` tool, specifically designed to work with `Kubernetes`. It can handle all the required operations for obtaining, renewing and using `SSL/TLS` certificates. Cert-Manager is able to talk with various certificate authorities (or CAs), like: [Let's Encrypt](https://letsencrypt.org/), [HashiCorp Vault](https://www.vaultproject.io/), and [Venafi](https://www.venafi.com/), and issue valid certificates for you automatically. On top of that, it can also take care of automatic certificate renewal before expiration.

Why do you need `SSL/TLS` certificates ?

First, and the most important aspect is verifying the `identity` of a host or site. You need to make sure that the person or company holding a website is to be trusted. This is a very important aspect, because you do not want to give your personal data (or even credit card details) to anyone.

Second important aspect deals with `sensitive data` which must be `encrypted`. The communication channel should never use a simple `HTTP` scheme, which is basically a `plain-text` protocol under the hood. In other words, data must travel encrypted between the two parties (meaning you, and the website).

Where does all this fit?

`Cert-Manager` goes hand in hand with your `Ingress Controller` resource. An `Ingress Controller` is the main entrypoint of your `Kubernetes` cluster, and sits in front of your `backend services`. So, by securing your ingress resources (e.g. `Nginx`), sensitive data never goes in or out un-encrypted. On top of that, you provide identity information to users, by presenting them a valid SSL/TLS certificate whenever they visit your website(s). Self-signed certificates are not to be trusted, and should never be used in production systems.

Please make sure to visit the Cert-Manager [official documentation](https://cert-manager.io/docs/) page to study more.

**Note:**

DigitalOcean is using `Helm v3` to deploy `Cert-Manager` to your `DOKS` cluster.

## Cert-Manager Overview Diagram

Below diagram is a simple example showing how `Cert-Manager` works in conjunction with the `Nginx Ingress Controller`:

![Cert-Manager and Nginx Overview](assets/images/arch_nginx_cert_manager.png)

## Software Included

| Package | Cert-Manager Version | Helm Chart Version | License |
|---------|----------------------|--------------------|---------|
| Cert-Manager | [1.6.1](https://github.com/cert-manager/cert-manager/releases/tag/v1.6.1) | [1.6.1](https://artifacthub.io/packages/helm/cert-manager/cert-manager/1.6.1) | [Apache 2.0](https://github.com/cert-manager/cert-manager/blob/master/LICENSE) |

## Getting Started

### How to Connect to Your Cluster

Follow these [instructions](https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/) to connect to your cluster with `kubectl` and `doctl`. Additional instructions for connecting to your cluster are included in the [DigitalOcean Control Panel](https://cloud.digitalocean.com/kubernetes/clusters/).

### How to confirm that Cert-Manager is running

First, check if the Helm installation was successful, by running below command:

```console
helm ls -n cert-manager
```

The output looks similar to (the `STATUS` column value should be `deployed`):

```text
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
cert-manager    cert-manager    1               2022-02-21 18:49:08.264191 +0200 EET    deployed        cert-manager-v1.6.1     v1.6.1
```

Next, verify if the Cert-Manager Pods are up and running:

```console
kubectl get pods -n cert-manager
```

The output looks similar to (all Pods should be in a `READY` state, and `STATUS` should be `Running`):

```text
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-57d89b9548-94r5z              1/1     Running   0          3m24s
cert-manager-cainjector-5bcf77b697-hkv2k   1/1     Running   0          3m24s
cert-manager-webhook-9cb88bd6d-mxhgh       1/1     Running   0          3m24s
```

### Tweaking Helm Chart Values

The `cert-manager` stack provides some custom values to start with. Please have a look at the [values](./values.yml) file from the main GitHub repository (explanations are provided inside, where necessary).

You can always inspect all the available options, as well as the default values for the `cert-manager` Helm chart by running below command:

```console
helm show values jetstack/cert-manager --version 1.6.1
```

After tweaking the Helm values file (`values.yml`) according to your needs, you can always apply the changes via `helm upgrade` command, as shown below:

```console
helm upgrade cert-manager jetstack/cert-manager --version 1.6.1 \
  --namespace cert-manager \
  --values values.yml
```

### Configuring TLS Certificates via Cert-Manager

Cert-Manager expects some typical CRDs to be created in order to operate. You start by creating a certificate [Issuer](https://cert-manager.io/docs/concepts/issuer/) CRD. Next, the `Issuer` CRD will try to fetch a valid TLS certificate for your Ingress Controller (e.g. Nginx) from a known authority, such as [Let's Encrypt](https://letsencrypt.org/). To accomplish this task, the `Issuer` is using the `HTTP-01` challenge (it also knows how to perform `DNS-01` challenges as well, for wildcard certificates).

Next, a [Certificate](https://cert-manager.io/docs/concepts/certificate/) CRD is needed to store the actual certificate. The `Certificate` CRD doesn't work alone, and needs a reference to an `Issuer` CRD to be able to fetch the real certificate from the `CA` (Certificate Authority).

Typical `Issuer` manifest looks like below (explanations for each relevant field is provided inline):

```yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-nginx
  namespace: backend
spec:
  # ACME issuer configuration
  # `email` - the email address to be associated with the ACME account (make sure it's a valid one)
  # `server` - the URL used to access the ACME server’s directory endpoint
  # `privateKeySecretRef` - Kubernetes Secret to store the automatically generated ACME account private key
  acme:
    email: <YOUR_VALID_EMAIL_ADDRESS_HERE>
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-nginx-private-key
    solvers:
      # Use the HTTP-01 challenge provider
      - http01:
          ingress:
            class: nginx
```

Next, you need to configure each Nginx ingress resource to use TLS termination. Typical manifest looks like below:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-echo
  namespace: backend
  annotations:
    cert-manager.io/issuer: letsencrypt-nginx
spec:
  tls:
  - hosts:
    - echo.my-domain.org
    secretName: letsencrypt-nginx
  rules:
    - host: echo.my-domain.org
...
```

Explanation for the above configuration:

- `cert-manager.io/issuer`: Annotation that takes advantage of cert-manager ingress-shim to create the certificate resource on your behalf.
- `spec.tls.hosts`: List of hosts included in the TLS certificate.
- `spec.tls.secretName`: Name of the secret used to terminate TLS traffic on port 443.

Notice that the `Nginx Ingress Controller` is able to generate the `Certificate` CRD automatically via a special annotation: `cert-manager.io/issuer`. This saves work and time, because you don't have to create and maintain a separate manifest for certificates as well (only the `Issuer` manifest is required). For other ingresses you may need to provide the `Certificate` CRD as well.

### Upgrading Cert-Manager Stack

You can check what versions are available to upgrade, by navigating to the [cert-manager](https://github.com/cert-manager/cert-manager/releases) official releases page from GitHub. Alternatively, you can also use [ArtifactHUB](https://artifacthub.io/packages/helm/cert-manager/cert-manager), which provides a more rich and user friendly interface.

Then, to upgrade the stack to a newer version, please run the following command (make sure to replace the `<>` placeholders first):

```console
helm upgrade cert-manager jetstack/cert-manager \
  --version <CERT_MANAGER_NEW_VERSION> \
  --namespace cert-manager \
  --values <YOUR_HELM_VALUES_FILE>
```

See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation.

Also, please make sure to check the official recommendations for various [upgrade paths](https://cert-manager.io/docs/installation/upgrading/), from an existing release to a new major version of cert-manager.

### Uninstalling Cert-Manager Stack

To delete your installation of `cert-manager`, please run the following `Helm` command:

```console
helm uninstall cert-manager -n cert-manager
```

**Note:**

Above command will delete all the associated `Kubernetes` resources installed by the `cert-manager` Helm chart, except the namespace itself. To delete the `cert-manager namespace` as well, please run below command:

```console
kubectl delete ns cert-manager
```

### Additional Resources

You can visit the [Starter Kit](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/) set of guides provided by DigitalOcean for further study. Specifically for `Cert-Manager`, you can access the following content:

- [Configuring Production Ready TLS Certificates for Nginx](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/nginx.md#step-5---configuring-production-ready-tls-certificates-for-nginx).
- [Configuring Wildcard Certificates via Cert-Manager](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/guides/wildcard_certificates.md).

To further enrich your experience, you can also browse the list of available [tutorials](https://cert-manager.io/next-docs/tutorials/) from the official `Cert-Manager` documentation site.
