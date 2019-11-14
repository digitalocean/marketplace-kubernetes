# Description

Configuring a webserver or loadbalancer is harder than it should be. Most webserver configuration files are very similar. There are some applications that have weird little quirks that tend to throw a wrench in things, but for the most part you can apply the same logic to them and achieve a desired result.

The [Kubernetes Ingress resource](http://kubernetes.io/docs/user-guide/ingress/) embodies this idea, and an Ingress controller is meant to handle all the quirks associated with a specific "class" of Ingress.

The NGINX Ingress Controller is built around the [Kubernetes Ingress resource](http://kubernetes.io/docs/user-guide/ingress/), using a [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#understanding-configmaps-and-pods) to store the NGINX configuration.

The NGINX Ingress Controller is a daemon, deployed as a Kubernetes Pod, that watches the apiserver's /ingresses endpoint for updates to the Ingress resource. Its job is to satisfy requests for Ingresses.

**Note:** The NGINX Ingress Controller 1-Click App also includes a $10/month DigitalOcean Load Balancer to ensure that ingress traffic is distributed across all of the nodes in your Kubernetes cluster.

# Getting Started

### How to Connect to Your Cluster
[Follow these instructions](https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/) to connect to your cluster with `kubectl` and `doctl`. Additional instructions for connecting to your cluster are included in the [DigitalOcean Control Panel](https://cloud.digitalocean.com/kubernetes/clusters/). 

You may also connect to your cluster without using `doctl` if you have taken the following prerequisite steps:
1. Created a cluster in the [DigitalOcean Control Panel](https://cloud.digitalocean.com/kubernetes/clusters/).
1. Downloaded the Kubernetes config file to ~/Downloads directory on your local machine. The config file will have a name like `nginx-k8s-1-15-3-do-1-sfo-kubeconfig.yaml`.
1. Installed the Kubernetes command line tool, `kubectl`, on your local machine. [(Here are instructions for doing that)](https://kubernetes.io/docs/tasks/tools/install-kubectl/) if you have not already done so.

After you complete those prerequisites, copy the Kubernetes config file to the default directory `kubectl` looks in.
```
cp ~/.kube/config  ~/.kube/config.bkup
```
```
cp  ~/Downloads/monitoring-k8s-1-15-3-do-1-sfo-kubeconfig.yaml  ~/.kube/config
````
You should now be able to connect to your DigitalOcean Kubernetes cluster and successfully run commands like:
```
kubectl get pods -A
```

### How to confirm that NGINX Ingress Controller is running

Verify Nginx Ingress was installed correctly by running this command:

```
kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx
```                                                                                                       

You should get output similar to the following:

```
NAMESPACE       NAME                                        READY   STATUS    RESTARTS   AGE
ingress-nginx   nginx-ingress-controller-7fb85bc8bb-4s2sl   1/1     Running   0          152m
```

Then, get the IP address of your NGINX Ingress Controller Load Balancer by running this command:

```
kubectl get svc ingress-nginx  -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[*].ip}'
```                                                                              




