# Description

[Nginx](https://github.com/kubernetes/ingress-nginx/) is a very popular `Ingress Controller`, and sits at the `edge` of your `VPC` acting as an entry point for your network. It knows how to handle and route `HTTP` requests to your web applications, thus it operates at `layer 7` of the `OSI` model.

When `Nginx` is deployed to your `DOKS` cluster, a `Load Balancer` is created as well, through which it receives the outside traffic. Then, you will have a `domain` set up with `A` type records (hosts), which in turn point to your load balancer `external IP`. So, data flow goes like this: `User Request -> Host.DOMAIN -> Load Balancer -> Ingress Controller (NGINX) -> Backend Applications (Services)`.

In a real world scenario, you do not want to use one `Load Balancer` per service, so you need a proxy inside the cluster. That is `Ingress`. As with every Ingress Controller, `Nginx` allows you to define ingress objects. Each ingress object contains a set of rules that define how to route external traffic (HTTP requests) to your backend services. For example, you can have multiple hosts defined under a single domain, and then let `Nginx` take care of routing traffic to the correct host.

The Nginx Ingress Controller is deployed via [Helm](https://helm.sh/), thus it can be managed the usual way.

To know more about the community maintained version of the Nginx Ingress Controller, please make sure to check the [official documentation](https://kubernetes.github.io/ingress-nginx/) website as well.

**Notes:**

- DigitalOcean is using `Helm v3` to deploy the Nginx Ingress Controller to your DOKS cluster.
- The NGINX Ingress Controller 1-Click App also includes a $10/month DigitalOcean Load Balancer to ensure that ingress traffic is distributed across all of the nodes in your Kubernetes cluster.

## Software Included

| Package | Application Version | Helm Chart Version | License |
|---------|---------------------|--------------------| ------- |
| Nginx Ingress Controller | 1.1.0 | [4.0.13](https://github.com/kubernetes/ingress-nginx/tree/helm-chart-4.0.13/charts/ingress-nginx)  | [Apache 2.0](https://github.com/kubernetes/ingress-nginx/blob/main/LICENSE) |

## Getting Started

### How to Connect to Your Cluster

Follow these [instructions](https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/) to connect to your cluster with `kubectl` and `doctl`. Additional instructions for connecting to your cluster are included in the [DigitalOcean Control Panel](https://cloud.digitalocean.com/kubernetes/clusters/).

### How to confirm that NGINX Ingress Controller is running

First, check if the Helm installation was successful, by running below command:

```console
helm ls -n ingress-nginx
```

The output looks similar to (the `STATUS` column value should be `deployed`):

```text
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
ingress-nginx   ingress-nginx   1               2022-02-14 12:04:06.670028 +0200 EET    deployed        ingress-nginx-4.0.13    1.1.0 
```

Next, verify if the Nginx Ingress Pods are up and running:

```console
kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx
```

The output looks similar to (all Pods should be in a `READY` state, and `STATUS` should be `Running`):

```text
NAMESPACE       NAME                                        READY   STATUS    RESTARTS   AGE
ingress-nginx   ingress-nginx-controller-664d8d6d67-6x4dd   1/1     Running   0          3m
ingress-nginx   ingress-nginx-controller-664d8d6d67-khm5x   1/1     Running   0          3m
```

Finally, you can inspect the external IP address of your NGINX Ingress Controller Load Balancer by running below command:

```console
kubectl get svc -n ingress-nginx
```

The output looks similar to (look for the `EXTERNAL-IP` column, containing a valid IP address):

```text
NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.245.156.128   67.207.70.117   80:31477/TCP,443:31171/TCP   3m
ingress-nginx-controller-admission   ClusterIP      10.245.18.58     <none>          443/TCP                      3m
ingress-nginx-controller-metrics     ClusterIP      10.245.193.76    <none>          10254/TCP                    3m
```

### Tweaking Helm Values

The Nginx Ingress stack provides some custom values to start with. Please have a look at the [values](./values.yml) file from the main GitHub repository (explanations are provided inside, where necessary).

You can always inspect all the available options, as well as the default values for the Nginx Ingress Helm chart by running below command:

```console
helm show values ingress-nginx/ingress-nginx --version 4.0.13
```

### Configuring Nginx Ingress Rules for Backend Services

To `expose` backend applications (services) to the outside world, you need to tell your `Ingress Controller` what `host` each `service` maps to. `Nginx` follows a simple pattern in which you define a set of `rules`. Each `rule` associates a `host` to a backend `service` via a corresponding path `prefix`.

Typical ingress resource for `Nginx` looks like below:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-echo
  namespace: backend
spec:
  ingressClassName: nginx
  rules:
    - host: echo.starter-kit.online
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: echo
                port:
                  number: 8080
```

Explanations for the above configuration:

- `spec.rules`: A list of host rules used to configure the Ingress. If unspecified, or no rule matches, all traffic is sent to the default backend.
- `spec.rules.host`: Host is the fully qualified domain name of a network host (e.g.: `echo.starter-kit.online`).
- `spec.rules.http`: List of http selectors pointing to backends.
- `spec.rules.http.paths`: A collection of paths that map requests to backends. In the above example the `/` path prefix is matched with the `echo` backend `service`, running on port `8080`.

The above ingress resource tells `Nginx` to `route` each `HTTP request` that is using the `/` prefix for the `echo.starter-kit.online` host, to the `echo` backend `service` running on port `8080`. In other words, every time you make a call to `http://echo.starter-kit.online/` the request and reply will be served by the `echo` backend `service` running on port `8080`.

### Upgrading the Nginx Ingress Chart

```console
helm upgrade [RELEASE_NAME] [CHART]
```

See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation.

### Upgrading With Zero Downtime in Production

By default the ingress-nginx controller has service interruptions whenever it's pods are restarted or redeployed. In order to fix that, see the excellent blog post by Lindsay Landry from Codecademy: [Kubernetes: Nginx and Zero Downtime in Production](https://medium.com/codecademy-engineering/kubernetes-nginx-and-zero-downtime-in-production-2c910c6a5ed8).

### Migrating from stable/nginx-ingress

There are two main ways to migrate a release from `stable/nginx-ingress` to `ingress-nginx/ingress-nginx` chart:

1. For Nginx Ingress controllers used for non-critical services, the easiest method is to uninstall the old release and install the new one.
2. For critical services in production that require zero-downtime, you will want to:

- Install a second Ingress controller.
- Redirect your DNS traffic from the old controller to the new controller.
- Log traffic from both controllers during this changeover.
- Uninstall the old controller once traffic has fully drained from it.
- For details on all of these steps see [Upgrading With Zero Downtime in Production](#upgrading-with-zero-downtime-in-production).

### Uninstalling the Nginx Ingress Controller

To delete your installation of NGINX Ingress Controller, please run the following `Helm` command:

```console
helm uninstall ingress-nginx -n ingress-nginx
```

### Additional Resources

You can visit the [Starter Kit](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/) set of guides provided by DigitalOcean for further study. Specifically for [Nginx](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/nginx.md), you can access the following content:

- [Configuring DNS for the Nginx Ingress Controller](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/nginx.md#step-2---configuring-dns-for-nginx-ingress-controller).
- [Creating some sample backend services to start with](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/nginx.md#step-3---creating-the-nginx-backend-services).
- [Configuring Ingress Rules for the sample backend services](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/nginx.md#step-4---configuring-nginx-ingress-rules-for-backend-services).
- [Configuring production ready TLS certificates for your Nginx Ingress Controller](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/nginx.md#step-5---configuring-production-ready-tls-certificates-for-nginx).
- [Enabling Proxy Protocol for your Nginx Ingress setup](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/nginx.md#step-6---enabling-proxy-protocol).

To further enrich your experience, we also provide the following extra guides:

- [Setting up wildcard certificates for Nginx Ingress](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/guides/wildcard_certificates.md).
- [Ingress Controller Load Balancer migration](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/guides/ingress_loadbalancer_migration.md).
- [Performance considerations for Nginx](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/guides/nginx_performance_considerations.md).
