## Description

[Ambassador Edge Stack](https://getambassador.io/) is a popular, high-performance [Ingress Controller](https://www.getambassador.io/products/edge-stack/api-gateway/) and [API Gateway](https://www.getambassador.io/learn/kubernetes-glossary/api-gateway/) built on [Envoy Proxy](https://www.envoyproxy.io/). Envoy Proxy was designed from the ground up for [cloud-native](https://www.getambassador.io/learn/kubernetes-glossary/cloud-native/) applications. Ambassador exposes Envoy's functionality as [Custom Resource Definitions](https://www.getambassador.io/learn/kubernetes-glossary/custom-resource-definition/), with integrated support for rate limiting, authentication, load balancing, observability, and more.

**Note:**

**Ambassador Edge Stack 2.X introduces some changes that aren't backward-compatible with 1.X, if you already have an existing installation that uses 1.X and you will like to upgrade to version 2.X please use the following [guide for upgrade](https://www.getambassador.io/docs/edge-stack/latest/topics/install/upgrade/helm/edge-stack-1.14/edge-stack-2.1/#upgrade-productname-1142-to-productname-version-helm).**

The DigitalOcean 1-click application installs the [Helm 3](https://helm.sh/docs/intro/install/) version of Ambassador Edge Stack.  This version includes the Authentication and Rate Limiting plugins as well as the Dev Portal.  It also includes the option of upgrading your installation to include Service Preview and MicroCD, two Edge Stack components that improve and streamline the developer self-service model.  To explore the features of these components, see the links below.

Edge Stack Components:

- [Rate Limiting](https://www.getambassador.io/docs/edge-stack/2.1/topics/using/rate-limits/rate-limits/): Rate limit to ensure the reliability, security and scalability of your microservices.
- [Authentication](https://www.getambassador.io/docs/edge-stack/2.1/topics/running/aes-extensions/authentication/): Built-in [OAuth2](https://www.getambassador.io/docs/edge-stack/2.1/topics/using/filters/oauth2/) and [JWT](https://www.getambassador.io/docs/edge-stack/2.1/topics/using/filters/jwt/) authentication with the ability to drop in custom AuthService plugins.

Note: This stack requires a minimum configuration of 2 Nodes at the $10/month plan (2GB memory / 1 vCPU).

Thank you to all the [contributors](https://github.com/datawire/ambassador/graphs/contributors) whose hard work make this software valuable for users.  If you'd like to contribute to the project, check out the [Ambassador Repository](https://github.com/datawire/ambassador) and submit a Pull Request!

## Software included

| Package               | Version                                        | License                                                                                    |
| --------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Ambassador Edge Stack | 2.1.2 | [Apache 2.0](https://github.com/datawire/ambassador/blob/master/LICENSE) |

## Getting Started

### Getting Started with DigitalOcean Kubernetes

As you get started with Kubernetes on DigitalOcean be sure to check out how to connect to your cluster using `kubectl` and `doctl`:
<https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/>

Additional instructions for configuring the [DigitalOcean Kubernetes](https://cloud.digitalocean.com/kubernetes/clusters/):

- [How to Set Up a DigitalOcean Managed Kubernetes Cluster (DOKS)](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/01-setup-DOKS#how-to-set-up-a-digitalocean-managed-kubernetes-cluster-doks)
- [How to Set up DigitalOcean Container Registry](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/02-setup-DOCR#how-to-set-up-digitalocean-container-registry)

### Getting started after deploying Ambassador Ingress Controller

Verify Ambassador Ingress was installed correctly by running this command:

```bash
helm ls -n ambassador
```

The output looks similar to (notice that the `STATUS` column value is `deployed`):

```text
NAME       NAMESPACE  REVISION UPDATED                              STATUS   CHART            APP VERSION
edge-stack ambassador 1        2022-02-14 18:02:21.554041 +0200 EET deployed edge-stack-7.2.2 2.1.2
```

After you deploy the stack you will need to configure a few more resources for the Ambassador Ingress Controller to work:

- The [Listener](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/ambassador.md#step-2---defining-the-listener-for-ambassador-edge-stack) Resource is required to configure which ports the Ambassador Edge Stack pods listen on so that they can begin responding to requests.
- The [Host](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/ambassador.md#step-3---defining-the-hosts-for-ambassador-edge-stack) Resource configures TLS termination for enablin HTTPS communication.
- The [Mapping](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/ambassador.md#step-6---configuring-the-ambassador-edge-stack-mappings-for-hosts) Resouce is used to configure routing requests to services in your cluster.

Please refer to the [Ambassador](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/ambassador.md) Ingress Controller tutorial, for more details about checking Ingress Controller deployment status and functionality.

### Uninstalling

To uninstall Ambassador Ingress Controller, you'll need to have Helm 3 installed. Once install, run the following:

```bash
helm uninstall edge-stack -n ambassador
```

followed by:

```bash
kubectl delete ns ambassador

kubectl delete -f https://app.getambassador.io/yaml/edge-stack/2.1.2/aes-crds.yaml
```

### Additional Resources

- [Quick Start](https://www.getambassador.io/docs/latest/tutorials/getting-started/)
- [Documentation](https://www.getambassador.io/docs/latest/)
- [Kubernetes Glossary](https://www.getambassador.io/learn/kubernetes-glossary/)
- [Ambassador Community Resources](https://www.getambassador.io/community/)
- [Community Slack Channel](https://join.slack.com/t/datawire-oss/shared_invite/zt-8rbpcp4x-vqcfpwmJYxcCVSL1CPxGLw)
- [FAQ](https://www.getambassador.io/docs/latest/about/faq/)
