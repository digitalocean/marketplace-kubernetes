## Summary
WordPress is Open Source software you can use to create a website, blog, or app.

## Description

[WordPress](https://wordpress.org/about/) is Open Source software designed for everyone, emphasizing accessibility, performance, security, and ease of use to create a website, blog, or app. [WordPress](https://en.wikipedia.org/wiki/WordPress) is a content managment system (CMS) built on PHP and using MySQL as a data store.

This DigitalOcean Marketplace Kubernetes 1-Click installs [WordPress](https://github.com/helm/charts/tree/master/stable/wordpress) and [MariaDB](https://github.com/helm/charts/tree/master/stable/mariadb) onto your Kubernetes cluster via [Helm Charts](https://helm.sh/). This 1-Click makes use of a [DigitalOcean LoadBalancer](https://www.digitalocean.com/products/load-balancer/) with [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) so you can view your WordPress site at a public URL. To help manage your data two [DigitalOcean Volumes](https://www.digitalocean.com/products/block-storage/) are used with Kubernetes [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) for the WordPress and MariaDB services.

Thank you to all the contributors whose hard work make WordPress valuable for users.


## Getting Started

### Getting Started with DigitalOcean Kubernetes
As you get started with Kubernetes on DigitalOcean be sure to check out [how to connect to your cluster](https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/) using `kubectl` and `doctl`.


Additional instructions are included in the DigitalOcean [Kubernetes control panel](https://cloud.digitalocean.com/kubernetes/clusters/).


#### Kubernetes Quick Start
If you just want to give this app a quick spin without `doctl` give the following a try.

Assuming you have done the following:
1. Created a cluster in the [DigitalOcean control panel](https://cloud.digitalocean.com/kubernetes/clusters/).
1. Downloaded the Kubernetes config file to ~/Downloads directory on your local machine. The config file will have a name like `wordpres-k8s-1-16-sfo-kubeconfig.yaml`.
1. Installed [Kubernetes command line tool](https://kubernetes.io/docs/tasks/tools/install-kubectl/), `kubectl`, on your local machine.

Copy the Kubernetes config file to the default directory `kubectl` looks in.
```
cp ~/.kube/config  ~/.kube/config.bkup
cp  ~/Downloads/wordpress-k8s-1-16-sfo-kubeconfig.yaml  ~/.kube/config
```
You should now be able to connect to your DigitalOcean Kubernetes Cluster and successfully run commands like:
```
kubectl get pods -A
```

### Confirm WordPress is running on Kubernetes
After you are able to successfully connect to your DigitalOcean Kubernetes cluster you’ll be able to see WordPress running in the `wordpress` namespace by issuing:
 ```
 kubectl get pods -n wordpress
 ```
 Confirm all `wordpress` pods are in a “`Running`” state under the “`STATUS`” column:

```
NAMESPACE             NAME                           READY   STATUS      RESTARTS   AGE
wordpress             wordpress-85589d5658-pxv8q     1/1     Running     0          10m
wordpress             wordpress-mariadb-0            1/1     Running     0          10m
```

### Connect to WordPress

1. Get the WordPress URL:

It may take a few minutes for the LoadBalancer IP to become available. Watch the status with:
```
kubectl get svc -n wordpress wordpress -w
```
(Press ctrl-c to stop watching for the LoadBalancer IP.)

Look for an IP address to be come available under `EXTERNAL-IP`. Get the IP by:
```
export WORDPRESS_IP=$(kubectl get svc -n wordpress wordpress -o jsonpath='{.status.loadBalancer.ingress[*].ip}')
```
```
echo "WordPress URL: http://$WORDPRESS_IP/"`
```
```
echo "WordPress Admin URL: http://$WORDPRESS_IP/admin"`
```

2. Login with the following credentials to see admin your WordPress site.

Username = `user`

Get the password:
```
echo Password: $(kubectl get secret --namespace wordpress wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)
```

Checkout the [WordPress docs](https://wordpress.org/support/) for more info on using WordPress. Happy hacking!
