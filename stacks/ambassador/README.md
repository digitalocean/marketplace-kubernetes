# Description
[Ambassador Edge Stack](https://getambassador.io/) is a popular, high-performance [Ingress Controller](https://www.getambassador.io/products/edge-stack/api-gateway/) and [API Gateway](https://www.getambassador.io/learn/kubernetes-glossary/api-gateway/) built on [Envoy Proxy](https://www.envoyproxy.io/). Envoy Proxy was designed from the ground up for [cloud-native](https://www.getambassador.io/learn/kubernetes-glossary/cloud-native/) applications. Ambassador exposes Envoy's functionality as [Custom Resource Definitions](https://www.getambassador.io/learn/kubernetes-glossary/custom-resource-definition/), with integrated support for rate limiting, authentication, load balancing, observability, and more.

The DigitalOcean 1-click application installs the [Helm 3](https://helm.sh/docs/intro/install/) version of Ambassador Edge Stack.  This version includes the Authentication and Rate Limiting plugins as well as the Dev Portal.  It also includes the option of upgrading your installation to include Service Preview and MicroCD, two Edge Stack components that improve and streamline the developer self-service model.  To explore the features of these components, see the links below.

Edge Stack Components:
  - [Rate Limiting](https://www.getambassador.io/docs/latest/topics/using/rate-limits/rate-limits/): Rate limit to ensure the reliability, security and scalability of your microservices.
  - [Authentication](https://www.getambassador.io/products/edge-stack/api-gateway/security-authentication): Built-in [OAuth2](https://www.getambassador.io/learn/kubernetes-glossary/oauth/) and [JWT](https://www.getambassador.io/learn/kubernetes-glossary/jwt/) authentication with the ability to drop in custom AuthService plugins.
  - [Dev Portal](https://www.getambassador.io/docs/latest/topics/using/dev-portal/): Lightweight, simple [API](https://www.getambassador.io/learn/kubernetes-glossary/api/) resource for OpenAPI and Swagger documentation.
  - [Service Preview](https://www.getambassador.io/docs/latest/topics/using/edgectl/): Develop locally as if you're in the cloud.  Service preview allows you to build and simulate a [microservice](https://www.getambassador.io/learn/kubernetes-glossary/microservices/) and respond as if it's in the cluster.
  - [MicroCD](https://www.getambassador.io/docs/latest/topics/using/projects/): Quick, streamlined [GitOps](https://www.getambassador.io/learn/kubernetes-glossary/gitops/) style development tool to quickly push out and share version 0 prototypes.

Note: This stack requires a minimum configuration of 2 Nodes at the $10/month plan (2GB memory / 1 vCPU).

Thank you to all the [contributors](https://github.com/datawire/ambassador/graphs/contributors) whose hard work make this software valuable for users.  If you'd like to contribute to the project, check out the [Ambassador Repository](https://github.com/datawire/ambassador) and submit a Pull Request!

# Software included

| Package               | Version                                        | License                                                                                    |
| --------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Ambassador Edge Stack | 1.6.0 | [Apache 2.0](https://github.com/datawire/ambassador/blob/master/LICENSE) |

# Getting Started

### Getting Started with DigitalOcean Kubernetes
As you get started with Kubernetes on DigitalOcean be sure to check out how to connect to your cluster using `kubectl` and `doctl`:
https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/
 
Additional instructions are included in the DigitalOcean Kubernetes control panel:
https://cloud.digitalocean.com/kubernetes/clusters/ 

#### Quick Start
If you just want to give this app a quick spin without `doctl` give the following a try.

Assuming you have done the following:
1. Created a cluster in the DigitalOcean control panel (https://cloud.digitalocean.com/kubernetes/clusters/).
1. Downloaded the Kubernetes config file to ~/Downloads directory on your local machine. The config file will have a name like `monitoring-k8s-1-15-3-do-1-sfo-kubeconfig.yaml`.
1. Installed Kubernetes command line tool, `kubectl`, (https://kubernetes.io/docs/tasks/tools/install-kubectl/) on your local machine.

Copy the Kubernetes config file to the default directory `kubectl` looks in.
```
cp ~/.kube/config  ~/.kube/config.bkup
cp  ~/Downloads/monitoring-k8s-1-15-3-do-1-sfo-kubeconfig.yaml  ~/.kube/config
```
You should now be able to connect to your DigitalOcean Kubernetes Cluster and successfully run commands like:
```
kubectl get pods -A
```

### Confirm Ambassador is running: 
After you are able to successfully connect to your DigitalOcean Kubernetes cluster you’ll be able to see Ambassador Operator running in the `ambassador` namespace by issuing:
 ```
 kubectl get pods -n ambassador
 ``` 
 Confirm all `ambassador` pods are in a “`Running`” state under the “`STATUS`” column:

```
NAME                                READY   STATUS    RESTARTS   AGE
ambassador-79c76bb8-64x96           1/1     Running   0          11m
ambassador-79c76bb8-bzlqn           1/1     Running   0          11m
ambassador-79c76bb8-c2b6x           1/1     Running   0          11m
ambassador-redis-6594476754-hgqbb   1/1     Running   0          11m
```

### Exposing a Service with Ambassador

To test our deployment, we are going to deploy a sample application to deliver random quotes to users.  The manifest below describes a Quote deployment exposed via a Quote service.

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: quote
spec:
  ports:
  - name: http
    port: 80
    targetPort: 8080
  selector:
    app: quote
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: quote
spec:
  replicas: 1
  selector:
    matchLabels:
      app: quote
  strategy:
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: quote
    spec:
      containers:
      - name: backend
        image: quay.io/datawire/quote:0.3.0
        ports:
        - name: http
          containerPort: 8080
```

1. Apply with `kubectl apply -f quote.yaml`.

1. We have our deployment and it's exposed with a service, but we still cannot connect to it without telling Ambassador where it is.  This is where the [Mapping](https://getambassador.io/docs/latest/topics/using/intro-mappings/) comes into play.  With a mapping, we can use kube-dns to let Ambassador know exactly where to look for the Quote service when the right request comes in.

    ```yaml
    ---
    apiVersion: getambassador.io/v2
    kind: Mapping
    metadata:
      name: backend
    spec:
      prefix: /backend/
      service: quote
    ```

1. Apply the mapping with `kubectl apply -f quote-backend.yaml`.

1. Test that it works by using `curl -k https://{{AMBASSADOR_IP}}/backend/` in your terminal.  You should see something similar to the following:

    ```bash
    {
        "server": "bleak-kumquat-n9qg6ra1",
        "quote": "Non-locality is the driver of truth. By summoning, we vibrate.",
        "time": "2020-05-08T18:33:54.578661743Z"
    }% 
    ```
    - The IP address can be obtained by running:
      ```bash
      kubectl get svc -n ambassador -o 'go-template={{range .status.loadBalancer.ingress}}{{print .ip "\n"}}{{end}}'
      ```

### Upgrading

To upgrade Ambassador Edge Stack, use the following:
```
kubectl apply -f https://www.getambassador.io/yaml/aes-crds.yaml
helm repo update && helm upgrade -n ambassador ambassador datawire/ambassador
```

### Additional Resources
  - [Quick Start](https://www.getambassador.io/docs/latest/tutorials/getting-started/)
  - [Documentation](https://www.getambassador.io/docs/latest/)
  - [Kubernetes Glossary](https://www.getambassador.io/learn/kubernetes-glossary/)
  - [Ambassador Community Resources](https://www.getambassador.io/community/)
  - [Community Slack Channel](https://join.slack.com/t/datawire-oss/shared_invite/zt-8rbpcp4x-vqcfpwmJYxcCVSL1CPxGLw)
  - [FAQ](https://www.getambassador.io/docs/latest/about/faq/)
