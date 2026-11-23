# Description

Simple Host Enterprise gives everyone in a company a place to publish what their AI
agent builds for them: a prototype, a tracker, a report. Each thing goes live at an
address under the person's own name, `<site>.<name>.<your domain>`, and only they
can open it until they share it with named colleagues, a team, or the whole company.
Colleagues find shared work by searching for the person who made it. Each person
can choose a published home page, write a short bio, pin sites and set their order.
The live showcase feed follows the existing company sign-in and sharing rules;
custom domains and short names are not available. Pages can save to key-value,
table and file storage, with a preset for who may read, add, edit and delete
(everyone reads the menu, each person sees only their own orders, the owner sees all).

Sign-in is the company's own identity provider (Google Workspace, Okta, Microsoft Entra
ID or any OIDC provider). Every publish and every visit is on record. Sites are static
pages with a small saved-data API, so a prototype can save data, and nothing is
provisioned per site: one service, one Postgres and one bucket serve everybody.

This 1-Click installs:

- Simple Host Enterprise (two replicas), pinned to a release by image digest.
- Postgres 16 in the cluster, with TLS, to start with. Nothing backs it up; use
  DigitalOcean Managed PostgreSQL before real use.
- Traefik behind a DigitalOcean load balancer with PROXY protocol, on an IngressClass
  of its own, so a controller the cluster already runs is left alone.
- cert-manager, if the cluster does not already have it.

Sites are stored in a DigitalOcean Spaces bucket, encrypted in the pod before upload.
Certificates come from Let's Encrypt through DigitalOcean DNS, including one wildcard
per person.

**Sizing:** two `s-2vcpu-4gb` nodes for a trial (two replicas on separate nodes, plus
the in-cluster database). For production, Managed PostgreSQL and a third node, so a
node can be replaced without losing a replica. Storage grows in Spaces, not in the
cluster.

Simple Host Enterprise is open source (Apache 2.0). Thank you to everyone who has
reported issues and contributed.

## Software Included

| Package | Version | License |
|---|---|---|
| [Simple Host Enterprise](https://github.com/vineetu/simple-host-enterprise) | v0.9.7 (chart 0.2.5) | [Apache 2.0](https://github.com/vineetu/simple-host-enterprise/blob/main/LICENSE) |
| [PostgreSQL](https://www.postgresql.org/) | 16.11 | [PostgreSQL](https://www.postgresql.org/about/licence/) |
| [Traefik](https://traefik.io/) | v3.7 (chart 41.6.0) | [MIT](https://github.com/traefik/traefik/blob/master/LICENSE.md) |
| [cert-manager](https://cert-manager.io/) | v1.21.2 | [Apache 2.0](https://github.com/cert-manager/cert-manager/blob/master/LICENSE) |

# Getting Started

### Getting Started with DigitalOcean Kubernetes

Connect to your cluster with `kubectl` and `doctl`:
https://docs.digitalocean.com/products/kubernetes/how-to/connect-to-cluster/

### Confirm Simple Host is installed

```
kubectl -n simple-host get pods
```

Right after install only the database runs; Simple Host starts once the settings
below are in:

```
NAME         READY   STATUS    RESTARTS   AGE
postgres-0   1/1     Running   0          1m
```

### Finish setup

You need:

1. **A domain of its own for Simple Host**, not a subdomain of the company's main
   domain, e.g. `corp-sites.com`, with its DNS hosted at DigitalOcean (Networking,
   Domains).
2. **An API token** with read and write on Domains, for certificates.
3. **A Spaces bucket** in the cluster's region with versioning on (command in the full
   guide), and a Spaces access key limited to it.
4. **An OIDC client** at your identity provider, with redirect URI
   `https://<domain>/auth/callback`.

Put them in `my-values.yaml`:

```yaml
host: corp-sites.com
oidc:
  issuer: https://accounts.google.com
  clientId: <client id>
  clientSecret: <client secret>
  adminEmails: you@example.com
  allowedEmailDomains: example.com
storage:
  endpoint: https://nyc3.digitaloceanspaces.com
  region: nyc3
  bucket: <bucket>
  accessKeyId: <Spaces key>
  secretAccessKey: <Spaces secret>
certificates:
  acme:
    email: you@example.com
    digitaloceanToken: <token>
```

Apply them:

```
helm upgrade simple-host-enterprise oci://ghcr.io/vineetu/charts/simple-host-enterprise --version 0.2.5 -n simple-host --reset-then-reuse-values -f my-values.yaml
```

Point `<domain>` and `*.<domain>` (two `A` records) at the load balancer's IP:

```
kubectl -n simple-host-ingress get svc traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Then open `https://<domain>` and sign in. People in `adminEmails` are admins.

Back up the envelope key. Every site in the bucket is unreadable without it:

```
(umask 077; kubectl -n simple-host get secret simple-host-secrets -o jsonpath='{.data.BACKUP_ENVELOPE_KEY}' | base64 -d > envelope-key.txt)
```

### Use it

Connect an AI app (Claude, ChatGPT, Cursor, VS Code) to `https://<domain>/mcp` and ask
it to publish what it made. Or publish from CI with an API key from the dashboard.

### Upgrade and remove

Upgrading from the Marketplace keeps your settings and moves to the new release.
Uninstalling deletes the `simple-host` namespace, and with it the database and the
envelope key: back the key up first. The Spaces bucket is left as it is.

### Managed database, versioning, and more

The full guide covers DigitalOcean Managed PostgreSQL, bucket versioning, using your own
certificate authority, and every setting:
https://github.com/vineetu/simple-host-enterprise/blob/main/docs/cloud/digitalocean.md

Support: support@simple-host.app
