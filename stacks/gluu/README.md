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

**Note: This stack requires a minimum configuration of 3 Nodes of machine type `CPU-Optimized nodes` at the $40/Month per node ($0.060/hr) plan (4GB memory / 2 vCPU).**

**Note: This stack may take up to 12 mins to start.**

# Software included

| Package               | Version                                        | License                                                                                    |
| --------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Gluu                  | [4.1](https://gluu.org/docs/gluu-server/4.1/)  | [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0.html)                             |
| oxd OAuth client      | [4.1](https://gluu.org/docs/oxd/4.1/)          | [AGPL](https://opensource.org/licenses/AGPL-3.0)                                           |
| Gluu Gateway  [alpha] | [4.2](https://gluu.org/docs/gg/4.2/)           | [Apache 2.0](https://raw.githubusercontent.com/GluuFederation/gluu-gateway/master/LICENSE) |
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

### Confirm Gluu is running:

After you are able to successfully connect to your DigitalOcean Kubernetes cluster you’ll be able to see Gluu running in the `gluu` namespace by issuing:

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

Check nginx ingress is running in `ningress` namespace:

```
kubectl get pods -n ningress
```

```
NAME                                                           READY   STATUS    RESTARTS   AGE
ingress-nginx-nginx-ingress-controller-7dc8cfdc5f-vsv9x        1/1     Running   0          88m
ingress-nginx-nginx-ingress-default-backend-6c4f68bfb6-lhmfp   1/1     Running   0          88m
```


Check gluu-gateway is running in `gluu-gateway` namespace:

**Note: Gluu-Gateway  is alpha in this installation**

```
kubectl get pods -n gluu-gateway
```

```
NAME                            READY   STATUS      RESTARTS   AGE
gg-kong-648ddf8f69-jtrdc        2/2     Running     2          71m
gg-kong-init-migrations-62vz7   0/1     Completed   0          71m
```

Check gluu-gateway ui is running in `gg-ui` namespace:

**Note: Gluu-Gateway UI is alpha in this installation**

```
kubectl get pods -n gg-ui
```

```
NAME                                     READY   STATUS      RESTARTS   AGE
ggui-gluu-gateway-ui-5db6c9dbf6-jdzhq    1/1     Running     0          69m
ggui-gluu-gateway-ui-preperation-nmt75   0/1     Completed   0          69m
```

### Connect/Use Gluu

1. Get the admin password by running the following script as `bash get_password.sh`. The password will be outputted to `admin_pass`. Save the admin password for login later in the admin UI.

    ```bash
    #!/bin/bash
    set -e
    mkdir delete_me && cd delete_me
    kubectl get secret gluu -o json -n gluu | grep '"encoded_salt":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]' > encoded_salt
    base64 -d encoded_salt > decoded_salt
    kubectl get secret gluu -o json -n gluu | grep '"encoded_ox_ldap_pw":' | sed -e 's#.*:\(\)#\1#' | tr -d '"' | tr -d "," | tr -d '[:space:]' > encoded_ox_ldap_pw
    base64 -d encoded_ox_ldap_pw > encoded_ox_ldap_pw_decoded
    cat <<EOF > decode.py
    #!/usr/bin/python3
    
    import sys
    import base64
    from pyDes import *
    
    key = ""
    with open('decoded_salt', 'r') as file:
    # PLACE YOUR decoded_salt BELOW
       key = file.read()
    
    encoded_ox_ldap_pw_decoded = ""
    with open('encoded_ox_ldap_pw_decoded', 'r') as file:
       encoded_ox_ldap_pw_decoded = file.read()
    
    def unobscure(s=""):
       engine = triple_des(key, ECB, pad=None, padmode=PAD_PKCS5)
       cipher = triple_des(key)
       decrypted = cipher.decrypt(base64.b64decode(s), padmode=PAD_PKCS5)
       return decrypted.decode('utf-8')
    
    with open('admin_pass', 'w+') as file:
       file.write(unobscure(encoded_ox_ldap_pw_decoded))
    
    EOF
    python3 decode.py
    ```
    
    Script steps explained:
    
    1. Make a directory called `delete_me`

    1. Get the `encoded_salt` from gluu secret
    
    1. Base64 decode the salt
       
    1. Get the `encoded_ox_ldap_pw`  from backend secret and save `encoded_ox_ldap_pw`  in a file called `encoded_ox_ldap_pw`

    1. Base64 decode the `encoded_ox_ldap_pw` and save the decoded `encoded_ox_ldap_pw` in a file called `encoded_ox_ldap_pw_decoded`

    1. Create the following python script as `decode.py` to decode your `encoded_ox_ldap_pw_decoded` by reading the salt and `encoded_ox_ldap_pw_decoded` files in the python snippet.
       
    1. Run script and the password will be outputted to file `admin_pass`.
    
1. Get the load balancer ip

    ```
    kubectl -n ningress get service ingress-nginx-nginx-ingress-controller --output jsonpath='{.status.loadBalancer.ingress[0].ip}'
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

- [Kubernetes Gluu installation recipies](https://gluu.org/docs/gluu-server/4.1/installation-guide/install-kubernetes/)
