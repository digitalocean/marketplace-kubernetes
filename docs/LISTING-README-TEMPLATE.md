# Description
**Focus on what this software is and the VALUE it brings to users.**
------
(replace all text in italics.)

_Write a few paragraphs about *WHAT* the listing is, *WHAT* the software does, and the *VALUE* it brings to users._

_Include specific details on what this 1-click provides, and the value to users. Enumerate the values this 1-click's config gives the user. Enumerate the value this software combination, specifically for apps containing multiple pieces of software, bring to the user._ 

_Include links for the user to learn more about the software that are not included in the software included section._

_Recommend CPU and Memory minimum requirements and node pools for test/dev and production for X amount of user._

_If your software is Open Source, a thank you to all the contributors is a nice touch. Suggest to add something to the effect:_
Thank you to all the contributors whose hard work make this software valuable for users.


# Getting Started
(Replace `[app]` with the specific app name.)

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

### Confirm [app] is running: 
After you are able to successfully connect to your DigitalOcean Kubernetes cluster you’ll be able to see [app] running in the `[app]` namespace by issuing:
 ```
 kubectl get pods -A
 ``` 
 Confirm all `[app]` pods are in a “`Running`” state under the “`STATUS`” column:

```
NAMESPACE    NAME                          READY    STATUS    RESTARTS    AGE
[app]    [app]-677f58bd99-fx47c    4/4      Running   0           6m34s
[app]    [app]-9dbd66dfb-52flb     2/2      Running   0           6m33s
[app]    [app]-6587f85db7-6vfkf    2/2      Running   0           6m35s
[app]    [app]-7cb697456b-jdq6t    2/2      Running   0           6m33s
[app]    [app]-7c45798d44-rxhnq    2/2      Running   0           6m32s
[app]    [app]-6d5b85476c-nf445    2/2      Running   0           6m34s
```
_Be sure to call out all apps the user needs to ensure are running for proper function of the `[app]`._

### Install [app] CLI (optional)

### Connect/Use [app]
_Provide detailed step-by-step instructions on how the user should interact and use the [app]. Be verbose and specific don't assume the user knows steps to take._

_Ensure the app provides some utility out of the box. Be comfortable to be opinionated on recommended config. Success is when the user can easily use the software, and utilize best practices with minimal effort. So be opinionated, and include recommended config, charts, etc._

_If possible provide an example app, chart, or module which allows the user to see how the [app] works, and enables the user to quickly start modifying and building._

_Include in-line documentation when possible._

_Include screen shots and images when possible_ 

![alt text][image]

[image]: https://assets.digitalocean.com/blog/static/sammy-the-shark-gets-a-birthday-makeover-from-simon-oxley/sammy-jetpack.png "Image Text"

_Provide Quick Getting Started YouTube videos when possible._

[![YouTube Video](http://img.youtube.com/vi/UMfJNg_SVj0/0.jpg)](http://www.youtube.com/watch?v=UMfJNg_SVj0 "Image Title")

_Repeat this section for each app in the application listing._

### Additional Resources
_Provide links to blogs, tutorials, documentation, and YouTube videos the user can leverage to grow knowledge about the [app]._

_Provide resources the user can use to go beyond deploying and initial setup._

### Examples
- https://marketplace-staging.digitalocean.com/apps/linkerd
- https://marketplace-staging.digitalocean.com/apps/kubernetes-monitoring-stack
- https://marketplace-staging.digitalocean.com/apps/openfaas-kubernetes

Markdown reference:
https://guides.github.com/features/mastering-markdown/
