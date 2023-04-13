# Description

[Knative](https://knative.dev) is an open-source solution to build and deploy serverless applications using Kubernetes as the underlying platform. In addition to application development, developers may also have infrastructure tasks such as maintaining Kubernetes manifests for application deployment, rolling back to a previous revision, traffic routing, scaling up or down workloads to meet load demand, etc. Knative reduces the boilerplate needed for spinning up workloads in Kubernetes, such as creating deployments, services, ingress objects, etc. Knative also helps you implement best practices in production systems (e.g. blue-green, canary deployments), application observability (logs and metrics), and support for event-driven applications.

Knative comprises of two main components:

- [Serving](https://knative.dev/docs/serving): Abstracts all required parts needed for your application to run and be accessible to the outside world.
- [Eventing](https://knative.dev/docs/eventing): Adds support for event based programming, thus making it easy to create event driven architectures.

Knative Serving features include:

- Deploy serverless applications quickly.
- Autoscaling for application pods (down scaling to zero is supported).
- Point-in-time snapshots for application code and configurations (via revisions).
- Routing and network programming. Supports multiple networking layers, like: [Kourier](https://github.com/knative-sandbox/net-kourier), [Contour](https://projectcontour.io), [Istio](https://istio.io).

Knative Eventing helps address common tasks for cloud native development such as:

- Enabling late-binding for event sources and consumers.
- Loose coupling between services, thus making easy to deploy individual application components.
- Various services can be connected without modifying consumers or producers, thus facilitating building new applications.

## Knative Serving Overview Diagram

The diagram below shows a simplified overview of how Knative Serving works:

![Knative Serving Overview](assets/images/arch_knative_serving.png)

**Notes:**

- DigitalOcean uses the [Knative Operator](https://github.com/knative/operator) to deploy Knative and the required components (Serving and Eventing) to your DOKS cluster.
- The Knative 1-Click App deploys Kourier as the default Ingress Controller for Knative.
- The Knative 1-Click App also includes a $10/month DigitalOcean Load Balancer to ensure that ingress traffic is distributed across all Knative services.

## Requirements

Minimum system requirements for Knative are as follows:

- A DOKS cluster running Kubernetes version 1.21.
- A DOKS cluster with 2 nodes, each with 2 CPUs, 4 GB of memory, and 20 GB of disk storage.

## Software Included

| Package | Application Version | License |
|---------|---------------------|---------|
| Knative Operator | [1.5.1](https://github.com/knative/operator/releases/tag/knative-v1.5.1) | [Apache 2.0](https://github.com/knative/operator/blob/main/LICENSE) |
| Knative Serving | [1.5.0](https://github.com/knative/serving/releases/tag/knative-v1.5.0) | [Apache 2.0](https://github.com/knative/serving/blob/main/LICENSE) |
| Knative Eventing | [1.5.0](https://github.com/knative/eventing/releases/tag/knative-v1.5.0) | [Apache 2.0](https://github.com/knative/eventing/blob/main/LICENSE) |

## Getting Started

### Connecting to Your Cluster

Follow these [instructions](https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/) to connect to your cluster with `kubectl` and `doctl`.

### Confirming Knative Operator is Running

First, check if the `Knative Operator` installation was successful by running command below:

```console
kubectl get deployment knative-operator
```

The output looks similar to the following:

```text
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
knative-operator   1/1     1            1           85s
```

Check the `READY` column value to make sure that all `knative-operator` deployment pods are up and running.

Finally, inspect `knative-operator` logs (and check for possible issues, if any):

```console
kubectl logs -f deploy/knative-operator
```

### Confirming that Knative Serving is Running

Serving is one of the main components of Knative. Check if it is running by using the following command:

```console
kubectl get KnativeServing knative-serving -n knative-serving
```

The output looks similar to the following:

```text
NAME              VERSION   READY   REASON
knative-serving   1.5.0     True
```

The `READY` column should have a value of `True`.

Then, run the following command to check if all Knative Serving deployments are healthy:

```console
kubectl get deployment -n knative-serving
```

The output looks similar to:

```text
NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
3scale-kourier-gateway   1/1     1            1           3h17m
activator                1/1     1            1           3h17m
autoscaler               1/1     1            1           3h17m
autoscaler-hpa           1/1     1            1           3h17m
controller               1/1     1            1           3h17m
domain-mapping           1/1     1            1           3h17m
domainmapping-webhook    1/1     1            1           3h17m
net-kourier-controller   1/1     1            1           3h17m
webhook                  1/1     1            1           3h17m
```

All important application components such as  `autoscaler`, `controller`, `domain-mapping`, `net-kourier-controller`, etc. should be up and running. If some are failing to start, check the affected component's events and logs.

### Confirming that Knative Eventing is Running

Check if Eventing is running by using the following command:

```console
kubectl get KnativeEventing knative-eventing -n knative-eventing
```

The output looks similar to:

```text
NAME               VERSION   READY   REASON
knative-eventing   1.5.0    True
```

Then, run the following command to check if all Knative Eventing deployments are healthy:

```console
kubectl get deployment -n knative-eventing
```

The output looks similar to:

```text
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
eventing-controller     1/1     1            1           3h21m
eventing-webhook        1/1     1            1           3h21m
imc-controller          1/1     1            1           3h21m
imc-dispatcher          1/1     1            1           3h21m
mt-broker-controller    1/1     1            1           3h21m
mt-broker-filter        1/1     1            1           3h21m
mt-broker-ingress       1/1     1            1           3h21m
pingsource-mt-adapter   0/0     0            0           3h21m
sugar-controller        1/1     1            1           3h21m
```

All important application components such as  `eventing-controller`, `imc-controller`, `mt-broker-controller`, `mt-broker-ingress`, etc. should be up and running. If some are failing to start, check the affected component's events and logs.

### Configuring the Knative Operator

All aspects of a Knative installation are managed by the Knative Operator. Configuration is done using ConfigMaps prefixed using `config-`. System ConfigMaps are accessible from the same namespace where the operator is deployed, which is usually the `default` namespace. Check the ConfigMaps:

```console
kubectl get cm
```

The output looks similar to:

```text
NAME                   DATA   AGE
config-logging         1      41m
config-observability   1      41m
```

The recommended way to change the Operator ConfigMaps is via the associated Serving and Eventing components CRD. The Operator ensures that the configuration settings are propagated automatically to the corresponding resources. If you change them manually, every manual change gets automatically overwritten by the Knative Operator.

Also, before continuing with the next step, please make sure that you have properly configured [DNS](https://knative.dev/docs/install/operator/knative-with-operators/#configure-dns) for your Knative Operator deployment.

### Configuring the Knative Serving Component

The Knative Serving component is responsible with creating and managing your serverless applications, as well as all the associated resources for routing network traffic (such as  ingress objects), autoscaling, etc. It also takes care of creating point-in-time snapshots for your application configuration and code, called [Revisions](https://github.com/knative/specs/blob/main/specs/serving/knative-api-specification-1.0.md#revision).

A typical Serving CRD configuration looks like the following:

```yaml
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
spec:
  version: "1.5.0"
  ingress:
    kourier:
      enabled: true
  config:
    network:
      ingress-class: "kourier.ingress.networking.knative.dev"
```

Explanations for the above configuration:

- `spec.version`: Tells Knative Operator what version of `KnativeServing` to install in your DOKS cluster (for example, `1.5.0`).
- `spec.ingress` and `spec.config.network`: Tells Knative what implementation to use for the networking layer (for example, Kourier).

In the previous example, Knative uses Kourier as the default networking implementation to handle ingress configuration. You can also choose other available options such as Istio and Contour. Note that Kourier is the option which comes bundled with Knative. For the other networking implementations mentioned earlier, you need to install the stacks separately. For example, install the Istio stack.

**Note:**

The Knative Operator only permits upgrades or downgrades by one minor release version at a time. For example, if the current Knative Serving deployment is version `0.22.0`, you must upgrade to `0.23.0` before upgrading to `0.24.0`.

See the [Knative Serving CRD](https://knative.dev/docs/install/operator/configuring-serving-cr) official documentation for more details and available options.

### Configuring the Knative Eventing Component

The Knative Eventing component lets you to create event-driven architectures. A typical example is a processing pipeline such as image processing, where different components (or stages) respond to external events, and work together to deliver the final result. Based on the task that needs to be performed, a specific component (or set of components) listening for that particular event is triggered. Then, when the task is done, another event is triggered which signals other components in the system that processing is done, and that results are ready to be consumed.

Event-driven architectures allow loose coupling between components in the system. This has a tremendous advantage, meaning that new functionality can be added easily, without interfering or breaking other components. Event-based architectures use a message broker such as [Apache Kafka](https://kafka.apache.org) and [RabbitMQ](https://www.rabbitmq.com). Using brokers abstracts the details of event routing from the event producer and event consumer. In other words, applications need not to worry how a message (or event) travels from point A to B. The broker takes care of all the details, and routes each message (or event) correctly from the source to the destination (or multiple destinations).

A typical Eventing CRD configuration looks like the following:

```yaml
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  version: "1.5.0"
```

In the previous configuration, the Knative Operator installs the `1.5.0` version of `KnativeEventing` component in your DOKS cluster, via the `spec.version` field. If no version is specified, then the latest one available is picked automatically. You can also configure other options like message broker configurations, resources requests and limits for the underlying containers, etc.

**Note:**

The Knative Operator only permits upgrades or downgrades by one minor release version at a time. For example, if the current Knative Eventing deployment is version `0.18.x`, you must upgrade to `0.19.x` before upgrading to `0.20.x`.

See the official documentation for [Knative Eventing CRD](https://knative.dev/docs/install/operator/configuring-eventing-cr) for more details and available options.

### Creating a Serverless Application via Knative

For every serverless application you create, you must define a Knative Service CRD (not to be confused with the Kubernetes Service resource). Each Knative Service is handled by the Knative Serving component described previously. A Knative Service abstracts all the required implementation details for your application to run (e.g. Kubernetes deployments, exposing the application via Ingress objects, autoscaling, etc). In the end, you will be presented with a HTTP URL resource to access your custom application.

Knative can automatically scale down your applications to zero when not in use or idle (for example, when no HTTP traffic is present), which make your applications serverless.

A typical Service CRD configuration looks like the following:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello
spec:
  template:
    metadata:
      name: hello-world
    spec:
      containers:
        - image: gcr.io/knative-samples/helloworld-go
          ports:
            - containerPort: 8080
          env:
            - name: TARGET
              value: "World"
```

Create the service in a `knative-samples` namespace using `kubectl`:

```console
kubectl create ns knative-samples

kubectl apply -f https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/knative/assets/manifests/serving-example.yaml -n knative-samples
```

Now, check if the Knative service was created in the `knative-samples` namespace and is in a healthy state:

```console
kubectl get services.serving.knative.dev -n knative-samples
```

The output looks similar to:

```text
NAME    URL                                        LATESTCREATED   LATESTREADY   READY   REASON
hello   http://hello.knative-samples.example.com   hello-world     hello-world   True 
```

**Hint:**

You can also install the [Knative CLI tool](https://knative.dev/docs/install/client/install-kn) to get a more comprehensive output as shown below:

```text
kn service list -n knative-samples

# Sample output:
# NAME    URL                                        LATEST        AGE     CONDITIONS   READY   REASON
# hello   http://hello.knative-samples.example.com   hello-world   2m33s   3 OK / 3     True 
```

### Testing the Knative Service

Assuming that there is a valid [DNS](https://knative.dev/docs/install/operator/knative-with-operators/#configure-dns) set up, you can access the link shown in the above `URL` column:

```console
curl http://hello.knative-samples.example.com
```

Running the command displays the `Hello World!` message. Behind the scenes, Knative automatically created all the required resources, such as deployments, routes, revisions, etc, for your custom application.

**Hint:**

If you do not have a real DNS setup yet, you can quickly test the service by creating a local mapping in the `/etc/hosts` file using the following steps:

1. Fetch the public IP address of the DigitalOcean load balancer created by the Kourier ingress deployment:

    ```console
    kubectl get svc/kourier -n knative-serving
    ```

    The output looks similar to the following:

    ```text
    NAME      TYPE           CLUSTER-IP       EXTERNAL-IP       PORT(S)                      AGE
    kourier   LoadBalancer   10.245.147.203   188.166.137.187   80:30611/TCP,443:30228/TCP   47h
    ```

    The `EXTERNAL-IP` column gives you the Kourier ingress controller's public IP address.

2. Create a new entry for your Knative service in the `/etc/hosts` file by replacing the `<>` placeholders:

    ```text
    <YOUR_KOURIER_INGRESS_PUBLIC_IP_HERE> hello.knative-samples.example.com
    ```

3. Test your service:

    ```console
    curl http://hello.knative-samples.example.com
    ```

It takes several seconds for Knative to cold start your serverless application.

4. Get specific information about each resource type in the `knative-samples` namespace using the `kn` command:

- List available `services`:
  
```console
kn service list -n knative-samples
```

- List available `routes` for each service:

```console
kn route list -n knative-samples
```

- List available `revisions` for each service:

```console
kn revision list -n knative-sample
```

Refer to the official documentation to see all available options for the [Serving](https://knative.dev/docs/serving/#serving-resources) resources. Also, you can configure [custom domains](https://knative.dev/docs/serving/services/custom-domains) for your applications, and enable production-ready TLS certificates support via [Cert-Manager](https://knative.dev/docs/install/installing-cert-manager).

## Developing Event-Driven Applications Using Knative Eventing

When creating event-driven architectures, usually there are three main components involved:

1. Event producers, which are applications that fire specific events.
2. Event consumers or subscribers, and the associated triggers. A trigger defines what events a consumer (or subscriber) should respond to.
3. A broker that knows how to route all events from source to destination.

In a nutshell, the system is composed of event producers and consumers (or subscribers). Usually, consumers filter events and act only on specific triggers. Subscribers can also respond back with other events as well. A broker sits behind the scenes, acting like the backbone of the entire system. Its main job is to make sure that events are routed correctly from source to destination. Knative Eventing offers support for In-Memory brokers, which are recommended for development and quick testing only, as well as third-party implementations such as Apache Kafka, RabbitMQ, etc.

Knative services can act like the event producers and/or consumers. Acting both like a producer and consumer, allows the service to send back events as a response, which is required by processing pipelines.

The diagram below gives a quick overview of an event-driven system:

![Knative Eventing Overview](assets/images/arch_knative_eventing.png)

See [this example](https://knative.dev/docs/eventing/getting-started) to create and test Knative Eventing.

## Upgrading Knative Components via the Operator

All Knative components (Serving, Eventing) are managed by the Operator. First, check the [Knative Serving](https://github.com/knative/serving/releases) and [Knative Eventing](https://github.com/knative/eventing/releases) versions available for upgrade.

Then, adjust the `spec.version` field from the YAML manifest of respective Knative component. For Knative Serving, replace the `<>` placeholders in the following command:

```yaml
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  version: "<new-version>"
...
```

For Knative Eventing, replace the `<>` placeholders in the following command:

```yaml
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  version: "<new-version>"
...
```

Finally, to upgrade each Knative component to a newer version, replace the `<>` placeholders and run the following commands:

```console
kubectl apply -f <YOUR_KNATIVE_SERVING_MANIFEST_FILE>

kubectl apply -f <YOUR_KNATIVE_EVENTING_MANIFEST_FILE>
```

See [Upgrade via the Knative Operator Guide](https://knative.dev/docs/install/upgrade/upgrade-installation-with-operator) for more information on how to upgrade the components, as well as the allowed migration paths.

**Notes:**
Please also note that if you attempt to upgrade from version `0.x.x` to version `1.x.x` you will get a message in the `knative operator` informing you that: `Version migration is not eligible with message: not supported to upgrade or downgrade across the MAJOR version.` To upgrade to a `MAJOR` version you should remove the existing `Knative Serving` or `Knative Eventing` resources and add new ones as follows:

First remove the Knative Serving resource:

  ```console
  kubectl delete KnativeServing knative-serving -n knative-serving
  ```

  or Knative Eventing resource:

  ```console
  kubectl delete KnativeEventing knative-eventing -n knative-eventing
  ```

Next, add a new major version in the `spec.version` field of the Eventing/Serving CRDs shown above and apply with `kubectl`:

```console
kubectl apply -f <YOUR_KNATIVE_SERVING_MANIFEST_FILE>

kubectl apply -f <YOUR_KNATIVE_EVENTING_MANIFEST_FILE>
```

## Uninstalling Knative

Knative Operator prevents unsafe removal of Knative resources. Even if the Knative Serving and Knative Eventing resources are successfully removed, all the CRDs in Knative are still kept in the cluster. All your resources relying on Knative CRDs can still work.

Remove the Knative Serving resource:

```console
kubectl delete KnativeServing knative-serving -n knative-serving
```

Remove the Knative Eventing resource:

```console
kubectl delete KnativeEventing knative-eventing -n knative-eventing
```

Remove the Knative Operator:

```console
OPERATOR_VERSION="1.5.1"

kubectl delete -f "https://github.com/knative/operator/releases/download/knative-v${OPERATOR_VERSION}/operator.yaml"
```

Delete associated namespaces (including all custom resources):

```console
kubectl delete ns knative-serving

kubectl delete ns knative-eventing

kubectl delete ns knative-samples
```

### Additional Resources

For more information, see the following:

- [Knative Official Documentation](https://knative.dev/docs).
- [Knative Eventing - Getting Started](https://knative.dev/docs/getting-started/getting-started-eventing).
- [Knative Eventing Observability - Collecting Logs](https://knative.dev/docs/eventing/observability/logging/collecting-logs).
- [Knative Eventing Observability - Collecting Metrics](https://knative.dev/docs/eventing/observability/metrics/collecting-metrics).
- [Knative Serving Observability - Collecting Logs](https://knative.dev/docs/serving/observability/logging/collecting-logs).
- [Knative Serving Observability - Collecting Metrics](https://knative.dev/docs/serving/observability/metrics/collecting-metrics).
- [Knative Serving - Autoscaling Applications](https://knative.dev/docs/serving/autoscaling).
- [Knative Serving - Application Traffic Management](https://knative.dev/docs/serving/traffic-management).
- [Knative Services - Configure Resource Requests and Limits](https://knative.dev/docs/serving/services/configure-requests-limits-services).
