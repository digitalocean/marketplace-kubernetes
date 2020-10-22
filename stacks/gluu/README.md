# Description

The Gluu Server is a container distribution of free open source software (FOSS) for identity and access management (IAM). SaaS, custom, open source and commercial web and mobile applications can leverage a Gluu Server for user authentication, identity information, and policy decisions.

Common use cases include:

- Single sign-on (SSO)
- Mobile authentication
- API access management
- Two-factor authentication (2FA)
- Customer identity and access management (CIAM)
- Identity federation

The Gluu Server is a FOSS platform for IAM. 

### Open Web Standards

The Gluu Server can be deployed to support the following open standards for authentication, authorization, federated identity, and identity management:

- OAuth 2.0
- OpenID Connect
- User Managed Access 2.0 (UMA)
- SAML 2.0
- System for Cross-domain Identity Management (SCIM)
- FIDO Universal 2nd Factor (U2F)
- FIDO 2.0 / WebAuthn
- Lightweight Directory Access Protocol (LDAP)
- Remote Authentication Dial-In User Service (RADIUS)


This stack source is open source and supported by Gluu enterprise [subscriptions](https://www.gluu.org/pricing/).

Contributions on bug fixes and features will be kindly reviewed.

**Note: This stack requires a minimum configuration of 3 Nodes of machine type `CPU-Optimized nodes` at the $80/Month per node ($0.118/hr) plan (6GB memory / 4 vCPU). If all services are going to be enabled a minimum of 4 nodes are needed.**

**Note: This stack may take up to 12 mins to start.**

**Note: This stack is for demonstration. Please consult our [docs](<https://gluu.org/docs/gluu-server/4.2/installation-guide/install-kubernetes/>) for more details.**

# Software included

| Package               | Version                                        | License                                                                                    |
| --------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Gluu                  | [4.2](https://gluu.org/docs/gluu-server/4.2/)  | [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0.html)                             |
| oxd OAuth client      | [4.2](https://gluu.org/docs/oxd/4.2/)          | [AGPL](https://opensource.org/licenses/AGPL-3.0)                                           |
| Gluu Gateway  [beta ] | [4.2](https://gluu.org/docs/gg/4.2/)           | [Apache 2.0](https://raw.githubusercontent.com/GluuFederation/gluu-gateway/master/LICENSE) |
| Casa [beta]           | [4.2](https://gluu.org/docs/casa/4.2/)         | [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0.html)                             |

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
### Start Gluu Installation

1. Get the load balancer ip

    ```
    kubectl get service cloud-native-installer --output jsonpath='{.status.loadBalancer.ingress[0].ip}'
    157.230.197.222
    ```

1. Access GUI installation at `http://157.230.197.222` and complete installation steps from there.
    
### Confirm Gluu is running:

After you are able to successfully connect to your DigitalOcean Kubernetes cluster you’ll be able to see Gluu running in the namespace Gluu was installed in i.e `gluu` by issuing:

```
kubectl get pods -n gluu
``` 
 
Confirm all `Gluu` pods are in a “`Running`” state under the “`STATUS`” column:

```
NAME                                 READY   STATUS      RESTARTS   AGE
gluu-casa-56669b49f9-6lhm4           1/1     Running     4          74m
gluu-config-p6mqf                    0/1     Completed   0          74m
gluu-cr-rotate-8hwnw                 1/1     Running     0          74m
gluu-cr-rotate-dqv42                 1/1     Running     0          74m
gluu-cr-rotate-rqj4h                 1/1     Running     0          74m
gluu-jackrabbit-0                    1/1     Running     0          74m
gluu-key-rotation-78c7bdb4cd-kz2wf   1/1     Running     0          74m
gluu-ldap-backup-1591607400-qm4lv    0/1     Completed   0          28m
gluu-ldap-backup-1591608000-825fs    0/1     Completed   0          18m
gluu-ldap-backup-1591608600-bn4fd    0/1     Completed   0          8m7s
gluu-opendj-0                        1/1     Running     0          74m
gluu-oxauth-64769b6dbd-lb724         1/1     Running     3          74m
gluu-oxd-server-bd86998df-pm9gh      1/1     Running     0          74m
gluu-oxpassport-57cc7c59f5-hhmj8     1/1     Running     0          74m
gluu-oxshibboleth-0                  1/1     Running     2          74m
gluu-oxtrust-0                       1/1     Running     2          74m
gluu-persistence-4q5dv               0/1     Completed   0          74m
gluu-radius-7cbf9cd575-2grtl         1/1     Running     0          74m
```

Check nginx ingress is running in the chosen ingress namespace i.e ningress:

```
kubectl get pods -n ningress
```

```
NAME                                                           READY   STATUS    RESTARTS   AGE
ingress-nginx-nginx-ingress-controller-7dc8cfdc5f-vsv9x        1/1     Running   0          88m
ingress-nginx-nginx-ingress-default-backend-6c4f68bfb6-lhmfp   1/1     Running   0          88m
```


Check gluu-gateway is running in the namesapce gluu-gateway was installed in i.e `gluu-gateway`  if it was installed:

**Note: Gluu-Gateway  is beta in this installation**

```
kubectl get pods -n gluu-gateway
```

```
NAME                            READY   STATUS      RESTARTS   AGE
gg-kong-648ddf8f69-jtrdc        2/2     Running     2          71m
gg-kong-init-migrations-62vz7   0/1     Completed   0          71m
```

Check gluu-gateway ui is running in the namespace gluu gateway ui was installed in i.e `gg-ui` if it was installed:

**Note: Gluu-Gateway UI is beta in this installation**

```
kubectl get pods -n gg-ui
```

```
NAME                                     READY   STATUS      RESTARTS   AGE
ggui-gluu-gateway-ui-5db6c9dbf6-jdzhq    1/1     Running     0          69m
ggui-gluu-gateway-ui-preperation-nmt75   0/1     Completed   0          69m
```

### Clean up

1. Once installation has finished you may delete the loadbalancer for the GUI. 

    ```
    kubectl -n gluu delete service cloud-native-installer && kubectl -n gluu delete job cloud-native-installer 
    ```
    
### Connect/Use Gluu
    
1. Once installation has finished, get the load balancer ip from the ingress service. 

    ```
    kubectl -n <ingress-nginx-namespace>  get service <ingress-nginx-name> --output jsonpath='{.status.loadBalancer.ingress[0].ip}'
    157.230.197.224
    ```

1. Map it to `demoexample.gluu.org` at  `/etc/hosts` file on the machine that will access gluu.

    ```
    vi /etc/hosts
    
    157.230.197.224 demoexample.gluu.org
    ```
    
1. Open browser at `https://demoexample.gluu.org` to access Gluu admin UI. Use username `admin` and password from [step](#connectuse-gluu) one.

**Note: Gluu here will use a self-signed certificate. Please accept to move forward**

### Connect/Use Gluu Gateway

1. Open browser at `https://demoexample.gluu.org/gg-ui/` to access Gluu Gateway UI. Use username `admin` and password from [step](#connectuse-gluu) one.

### Connect/Use Casa

1. Open browser at `https://demoexample.gluu.org/casa` to access Casa. Use username `admin` and password from first [step](#connectuse-gluu) one.

### Additional Resources

- [Kubernetes Gluu installation recipies](https://gluu.org/docs/gluu-server/4.2/installation-guide/install-kubernetes/)
