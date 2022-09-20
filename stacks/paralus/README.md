# Paralus

Paralus is a free, open source project that enables **controlled, audited access to Kubernetes infrastructure** for your users, user groups, and services that ships as a GUI, API, and CLI.

It offers access management for developers, architects, and CI/CD tools to remote K8s clusters by consolidating zero-trust access principles such as transaction-level authentication and authorization into a single open-source tool. It helps engineering and architecture teams streamline access control for their fleet of Kubernetes clusters spanning different operating environments, different public clouds and Kubernetes distributions, and on-premises data centers operating behind firewalls.

Paralus can be easily integrated with your pre-existing **SSO providers**, or **Identity Providers (IdP)** that support **OIDC (OpenID Connect)**.

![Image](https://www.paralus.io/img/paralus_hld.png "Paralus Architecture")

## Features

- Creation of custom roles, users, and groups.
- Custom user role creation and revoking of permissions.
- Ability to control access via pre-configured roles across clusters, namespaces, projects, and more.
- Seamless integration with Identity Providers (IdPs) allowing the use of external authentication engines for users and group definitions, such as GitHub, Google, Azure AD, Okta, and others.
- Automatic logging of all user actions performed for audit and compliance purposes.
- Interact with Paralus either with a modern web GUI (default), a CLI tool called pctl, or Paralus API.

Read more about the components and how it works in the [Paralus documentation](https://www.paralus.io/docs/architecture/).

You can contribute to Paralus too. Check out our [Contribution guidelines](https://www.paralus.io/docs/references/contribution).

## Getting Started

Validate that Paralus is installed correctly by ensuring that all the pods are running

`kubectl get pods -n paralus`

Before you are able to use Paralus, there are a few things that you need to do.

You will not be able to access the Paralus dashboard if you skip any of the following steps.

### 1. Updating The Domain Name

Paralus makes use of domain based routing and hence you need to have a domain name with you to be able to access the Paralus dashboard.

Once the installation is complete, run the following command to update the domain name with your domain name.

```bash
helm upgrade paralus paralus/ztka -n paralus --values https://raw.githubusercontent.com/paralus/helm-charts/main/examples/values.dev-generic.yaml --set fqdn.domain="yourdomain.com"
```

> Replace `yourdomain.com` with your actual domain name.

### 2. Configuring DNS settings

To be able to access the Paralus dashboard, you also need to update the DNS settings of your domain to point to the IP address of the installation. Run the following command to fetch the IP address of the load balancer.

```bash
kubectl get svc paralus-contour-envoy -n paralus

NAME                      TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
paralus-contour-envoy   LoadBalancer   10.245.58.69   138.68.122.180   80:32722/TCP,443:32656/TCP   2m32s

```

Navigate to your domain name's DNS configuration page and create three CNAME records with the IP address of the load balancer you get in the above step.

| Type | Address | Resolves To | TTL |
|---|---|---|---|
| A | console.yourdomain.com | 138.68.122.180 | 1 Hour |
| A | *.core-connector.yourdomain.com | 138.68.122.180 | 1 Hour |
| A | *.user.yourdomain.com | 138.68.122.180 | 1 Hour |

### 3. Reset Default Password

Paralus is installed with a default organization and an admin user. Hence, after installation, you need to set a password for the user.

To do so, execute the following command

```bash
kubectl logs -f --namespace paralus $(kubectl get pods --namespace paralus -l app.kubernetes.io/name='paralus' -o jsonpath='{ .items[0].metadata.name }') initialize | grep 'Org Admin signup URL:'

Org Admin signup URL:  http://console.yourdomain.com/self-service/recovery?flow=de34efa4-934e-4916-8d3f-a1c6ce65ba39&token=IYJFI5vbORhGnz81gCjK7kucDVoiuQ7j

```

> The password reset URL is valid only for 10 minutes. In case you are unable to get the link, refer to our troubleshooting guide to regenerate the password reset URL.

Access the URL in a browser, and provide a new password.

### 4. Access Paralus Dashboard

In a new browser window/tab navigate to http://console.yourdomain.com and log in with the following credentials:

username: admin@paralus.local - or the one you specified in values.yml
password: <The one you entered above>

You'll be taken to the default project page.

![Image](https://www.paralus.io/img/docs/paralus-dashboard.png "Paralus Architecture")

You've successfully deployed Paralus.

Refer to [Paralus documentation](https://www.paralus.io/docs/) and [blog](https://www.paralus.io/blog) to know more about what you can do with Paralus.