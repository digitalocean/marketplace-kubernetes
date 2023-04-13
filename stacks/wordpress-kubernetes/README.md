# Description

[WordPress](https://wordpress.org/about/) is an Open Source software designed for everyone, emphasizing accessibility, performance, security, and ease of use to create a website, blog, or app. [WordPress](https://en.wikipedia.org/wiki/WordPress) is a content managment system (CMS) built on PHP and using MySQL as a data store, powering over 30% of internet sites today.

This DigitalOcean Marketplace Kubernetes 1-Click installs [WordPress](https://github.com/bitnami/charts/tree/master/bitnami/wordpress) and [MariaDB](https://github.com/bitnami/charts/tree/master/bitnami/mariadb) onto your Kubernetes cluster via [Helm Charts](https://helm.sh/). This 1-Click makes use of a [DigitalOcean LoadBalancer](https://www.digitalocean.com/products/load-balancer/) with [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) so you can view your WordPress site at a public URL. To help manage your data two [DigitalOcean Volumes](https://www.digitalocean.com/products/block-storage/) are used with Kubernetes [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) for the WordPress and MariaDB services.

**Notes:**

- This stack requires a minimum configuration of 2 Nodes at the $10/month plan (2GB memory / 1 vCPU).
- The WordPress 1-Click App also includes a $1/month block storage for both WordPress and MariaDB.
- The Wordpress 1-Click app also includes a $12/month DigitalOcean Load Balancer to ensure that ingress traffic is distributed across all of the nodes in your DOKS cluster.

## Software included

| Package               | Application Version   | Helm Chart Version |License                                                                                    |
| ---| ---- | ---- | ------------- |
| WordPress | 6.0.1 | [15.0.11](https://artifacthub.io/packages/helm/bitnami/wordpress/15.0.11) | [GPLv2](https://wordpress.org/about/license/) |
| MariaDB | 10.6.8 | [15.0.11](https://artifacthub.io/packages/helm/bitnami/wordpress/15.0.11) | [GPLv2](https://mariadb.com/kb/en/library/mariadb-license/) |

## Getting Started

### How to Connect to Your Cluster

As you get started with Kubernetes on DigitalOcean be sure to check out how to connect to your cluster using `kubectl` and `doctl`:
<https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/>

Additional instructions for configuring the [DigitalOcean Kubernetes](https://cloud.digitalocean.com/kubernetes/clusters/):

- [How to Set Up a DigitalOcean Managed Kubernetes Cluster (DOKS)](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/01-setup-DOKS#how-to-set-up-a-digitalocean-managed-kubernetes-cluster-doks)
- [How to Set up DigitalOcean Container Registry](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/02-setup-DOCR#how-to-set-up-digitalocean-container-registry)

### How to confirm that WordPress is running

First, check if the Helm installation was successful, by running below command:

```bash
helm ls -n wordpress
```

The output looks similar to (notice that the `STATUS` column value is `deployed`):

```text
NAME      NAMESPACE REVISION UPDATED                              STATUS   CHART             APP VERSION
wordpress wordpress 1        2022-03-10 14:56:39.419223 +0200 EET deployed wordpress-15.0.11 6.0.1
```

Next, verify if the WordPress and MariaDB Pods are up and running:

```console
kubectl get pods --all-namespaces -l app.kubernetes.io/instance=wordpress
```

The output looks similar to (all Pods should be in a `READY` state, and `STATUS` should be `Running`):

```text
NAMESPACE   NAME                         READY   STATUS    RESTARTS   AGE
wordpress   wordpress-5784c7bbfb-h7n9h   1/1     Running   0          12m
wordpress   wordpress-mariadb-0          1/1     Running   0          12m
```

Next, inspect the external IP address of your WordPress Load Balancer by running below command:

```console
kubectl get svc -n wordpress
```

The output looks similar to (look for the `EXTERNAL-IP` column, containing a valid IP address):

```text
NAME                TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE
wordpress           LoadBalancer   10.245.59.107   143.244.213.33   80:32589/TCP,443:32044/TCP   14m
wordpress-mariadb   ClusterIP      10.245.42.121   <none>           3306/TCP                     14m
```

Finally, WordPress stack should now be successfully installed and running

### Connect to WordPress

First, get the WordPress URL by using below command:

```console
kubectl get svc -n wordpress wordpress
```

The output looks similar to (notice the `EXTERNAL-IP` column value for the wordpress service):

```text
NAME        TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE
wordpress   LoadBalancer   10.245.59.107   143.244.213.33   80:32589/TCP,443:32044/TCP   46m
```

```console
export WORDPRESS_IP=$(kubectl get svc -n wordpress wordpress -o jsonpath='{.status.loadBalancer.ingress[*].ip}')
echo "WordPress URL: http://$WORDPRESS_IP/"
echo "WordPress Admin URL: http://$WORDPRESS_IP/admin"
```

Next, extract the credentials to see admin your WordPress site:

```console
kubectl get secret --namespace wordpress wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode
```

Finally, open a web browser and navigate to the WordPress admin panel using the `http://$WORDPRESS_IP/admin` address and login with the `admin` user and the password you got from the `kubernetes secret` above.

**Note:**
Once this chart is deployed, it is not possible to change the application's access credentials, such as usernames or passwords, using Helm. To change these application credentials after deployment, delete any persistent volumes (PVs) used by the chart and re-deploy it, or use the application's built-in administrative tools if available.

Checkout the [WordPress docs](https://wordpress.org/support/) for more info on using WordPress.

### Tweaking Helm Values

The WordPress stack provides some custom values to start with. Please have a look at the [values](./values.yml) file from the main GitHub repository (explanations are provided inside, where necessary).

You can always inspect all the available options, as well as the default values for the WordPress Helm chart by running below command:

```console
helm show values bitnami/wordpress --version 15.0.11
```

After tweaking the Helm values file (`values.yml`) according to your needs, you can always apply the changes via `helm upgrade` command, as shown below:

```console
helm upgrade wordpress bitnami/wordpress --version 15.0.11 \
  --namespace wordpress \
  --values values.yml
```

### Upgrading the WordPress Chart

You can check what versions are available to upgrade, by navigating to the [emissary-ingress](https://github.com/emissary-ingress/emissary) official releases page from GitHub. Alternatively, you can also use [ArtifactHUB](https://artifacthub.io/packages/helm/datawire/edge-stack), which provides a more rich and user friendly interface.

Then, to upgrade the stack to a newer version, please run the following command (make sure to replace the `<>` placeholders first):

```console
helm upgrade wordpress bitnami/wordpress \
  --version <WORDPRESS_STACK_NEW_VERSION> \
  --namespace wordpress \
  --values <YOUR_HELM_VALUES_FILE>
```

See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation.

### Uninstalling

To uninstall WordPress, you'll need to have Helm 3 installed. Once installed, run the following:

```bash
helm uninstall wordpress -n wordpress
```

followed by:

```bash
kubectl delete ns wordpress
```

### Additional Resources

To further enrich your experience, you can also visit the official WordPress Stack documentation sites:

- [Documentation](https://github.com/bitnami/charts/tree/master/bitnami/wordpress)
