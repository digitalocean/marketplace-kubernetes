# Description

[Ambassador Edge Stack](https://getambassador.io/) is an [Ingress Controller](https://www.getambassador.io/products/edge-stack/api-gateway/) and [API Gateway](https://www.getambassador.io/learn/kubernetes-glossary/api-gateway/) built on [Envoy Proxy](https://www.envoyproxy.io/). Envoy Proxy is designed for [cloud-native](https://www.getambassador.io/learn/kubernetes-glossary/cloud-native/) applications. Ambassador exposes Envoy's functionality as [Custom Resource Definitions](https://www.getambassador.io/learn/kubernetes-glossary/custom-resource-definition/), with integrated rate limiting, authentication, load balancing, and observability.

**Note:**

**Ambassador Edge Stack 2.X introduces some changes that aren't backwards-compatible with 1.X. If you already have an existing installation that uses 1.X and you want to upgrade to version 2.X, please use the following [guide for upgrade](https://www.getambassador.io/docs/edge-stack/latest/topics/install/upgrade/helm/edge-stack-1.14/edge-stack-2.1/#upgrade-productname-1142-to-productname-version-helm).**

The DigitalOcean 1-click application installs the [Helm 3](https://helm.sh/docs/intro/install/) version of Ambassador Edge Stack.  This version includes the Authentication and Rate Limiting plugins, as well as the Dev Portal. It also includes the option of upgrading your installation to include Service Preview and MicroCD, two Edge Stack components that improve and streamline the developer self-service model. To explore the features of these components, see the following links.

**Edge Stack Components:**

- [Rate Limiting](https://www.getambassador.io/docs/edge-stack/2.1/topics/using/rate-limits/rate-limits/): Rate limit to ensure the reliability, security and scalability of your micro-services.
- [Authentication](https://www.getambassador.io/docs/edge-stack/2.1/topics/running/aes-extensions/authentication/): Built-in [OAuth2](https://www.getambassador.io/docs/edge-stack/2.1/topics/using/filters/oauth2/) and [JWT](https://www.getambassador.io/docs/edge-stack/2.1/topics/using/filters/jwt/) authentication with the ability to drop in custom AuthService plugins.

**Note:**
This stack requires a minimum configuration of 2 Nodes at the $10/month plan (2GB memory / 1 vCPU).
The Ambassador 1-Click app also includes a $12/month DigitalOcean Load Balancer to ensure that ingress traffic is distributed across all of the nodes in your DOKS cluster.

## Software included

| Package               | Application Version   | Helm Chart Version |License                                                                                    |
| ---| ---- | ---- | ------------- |
| Ambassador Edge Stack | 2.2.2 | [7.3.2](https://artifacthub.io/packages/helm/datawire/edge-stack/7.3.2) | [Apache 2.0](https://github.com/datawire/ambassador/blob/master/LICENSE) |

## Getting Started

### Connecting to Your Cluster

You can connect to your DigitalOcean Kubernetes cluster by following our [how-to guide](https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/).

For additional instructions on configuring a [DigitalOcean Kubernetes](https://cloud.digitalocean.com/kubernetes/clusters/) cluster, see the following guides:

- [How to Set Up a DigitalOcean Managed Kubernetes Cluster (DOKS)](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/01-setup-DOKS#how-to-set-up-a-digitalocean-managed-kubernetes-cluster-doks)
- [How to Set up DigitalOcean Container Registry](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/02-setup-DOCR#how-to-set-up-digitalocean-container-registry)

### Confirming that Ambassador Ingress Controller is Running

First, verify that the Helm installation was successful by running following command:

```bash
helm ls -n ambassador
```

If the installation was successful, the `STATUS` column value in the output reads `deployed`:

```text
NAME       NAMESPACE  REVISION UPDATED                              STATUS   CHART            APP VERSION
edge-stack ambassador 1        2022-02-14 18:02:21.554041 +0200 EET deployed edge-stack-7.3.2 2.2.2
```

Next, verify that the Ambassador Ingress pods are up and running with the following command:

```console
kubectl get pods --all-namespaces -l app.kubernetes.io/name=edge-stack
```

If they're running, all pods listed in the output are in a `READY` state and the `STATUS` for each reads `Running`:

```text
NAMESPACE    NAME                          READY   STATUS    RESTARTS   AGE
ambassador   edge-stack-688f84d947-dv244   1/1     Running   0          5m39s
ambassador   edge-stack-688f84d947-r4qcs   1/1     Running   0          5m39s
ambassador   edge-stack-688f84d947-snzmh   1/1     Running   0          5m39s
```

Then, inspect the external IP address of your Ambassador Ingress Controller Load Balancer by running following command:

```console
kubectl get svc -n ambassador
```

If installed correctly, the output has the `EXTERNAL-IP` column, containing a valid IP address:

```text
NAME               TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE
edge-stack         LoadBalancer   10.245.88.194   134.209.131.93   80:32617/TCP,443:31000/TCP   6m19s
edge-stack-admin   ClusterIP      10.245.66.159   <none>           8877/TCP,8005/TCP            6m19s
edge-stack-redis   ClusterIP      10.245.188.44   <none>           6379/TCP                     6m19s
```

Finally, Ambassador Edge Stack should now be successfully installed and running, but in order to get started deploying Services and test routing to them you need to configure a few more resources:

- The [Listener](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/ambassador.md#step-2---defining-the-listener-for-ambassador-edge-stack) Resource is required to configure which ports the Ambassador Edge Stack pods listen on so that they can begin responding to requests.
- The [Mapping](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/ambassador.md#step-6---configuring-the-ambassador-edge-stack-mappings-for-hosts) Resouce is used to configure routing requests to services in your cluster.
- The [Host](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/ambassador.md#step-3---defining-the-hosts-for-ambassador-edge-stack) Resource configures TLS termination for enablin HTTPS communication.

For more details about checking Ingress Controller deployment status and functionality, lease refer to the [Ambassador](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/ambassador.md) Ingress Controller tutorial.

### Tweaking Helm Values

The Ambassador Ingress stack provides some custom values to start with. Please have a look at the [values](./values.yml) file from the main GitHub repository (explanations are provided inside, where necessary).

You can always inspect all the available options, as well as the default values for the Ambassador Ingress Helm chart by running below command:

```console
helm show values datawire/edge-stack --version 7.3.2
```

After tweaking the Helm values file (`values.yml`) according to your needs, you can always apply the changes via `helm upgrade` command, as shown below:

```console
helm upgrade edge-stack datawire/edge-stack --version 7.3.2 \
  --namespace ambassador \
  --values values.yml
```

### Upgrading the Ambassador Ingress Chart

You can check what versions are available to upgrade by navigating to the [emissary-ingress](https://github.com/emissary-ingress/emissary) official releases page from GitHub. Alternatively, you can use [ArtifactHUB](https://artifacthub.io/packages/helm/datawire/edge-stack).

To upgrade the stack to a newer version, run the following command, replacing the `< >` placeholders with their corresponding information:

```console
helm upgrade edge-stack datawire/edge-stack \
  --version <INGRESS_AMBASSADOR_STACK_NEW_VERSION> \
  --namespace ambassador \
  --values <YOUR_HELM_VALUES_FILE>
```

See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation.

### Uninstalling

To uninstall Ambassador Ingress Controller, you need to have Helm 3 installed. Once installed, run the following `uninstall` command:

```bash
helm uninstall edge-stack -n ambassador
```

And then the following `delete` commands:

```bash
kubectl delete ns ambassador

kubectl delete -f https://app.getambassador.io/yaml/edge-stack/2.3.0/aes-crds.yaml
```

### Additional Resources

- [Documentation](https://www.getambassador.io/docs/latest/)
- [Kubernetes Glossary](https://www.getambassador.io/learn/kubernetes-glossary/)
- [Ambassador Community Resources](https://www.getambassador.io/community/)
- [Community Slack Channel](https://join.slack.com/t/datawire-oss/shared_invite/zt-8rbpcp4x-vqcfpwmJYxcCVSL1CPxGLw)
- [FAQ](https://www.getambassador.io/docs/latest/about/faq/)
