# Description

[Plane](https://plane.so/) is an open-source project and issue tracking tool for planning
sprints, tracking cycles, and shipping products -- an alternative to Jira, Linear, and
Asana that you run yourself.

This 1-Click deploys **Plane Enterprise**, which includes a free tier with no license
required to start. If you later purchase a commercial plan, you attach a license key to
the same deployment -- there is no migration or reinstall involved. If you'd rather stay
on the fully open-source edition indefinitely, deploy [plane-ce](https://github.com/makeplane/helm-charts/tree/main/charts/plane-ce)
via `helm` directly instead.

This 1-Click provisions everything Plane needs to run standalone on a fresh DOKS
cluster, with no configuration required: a Traefik ingress controller, the API, web,
space, admin and real-time collaboration services, background workers, and bundled
Postgres, Valkey (Redis), RabbitMQ and MinIO -- all backed by DigitalOcean Block
Storage. It's reachable immediately at a working URL with no DNS setup (see
[Domain and access](#domain-and-access)).

DigitalOcean's Kubernetes 1-Click flow runs `deploy.sh` with no way for you to supply
values or environment variables, so this stack deliberately has no install-time
configuration options. If you want to swap a bundled service for a DigitalOcean Managed
Database/Spaces bucket, add TLS, or otherwise customize it, do that afterwards yourself
with `helm upgrade` directly -- see [Customizing beyond this 1-click](#customizing-beyond-this-1-click).

Thank you to all the contributors whose hard work makes Plane valuable for users.

## Software included

| Package         | Version | License                                                                  |
| ---------------- | ------- | ------------------------------------------------------------------------ |
| Plane Enterprise | v3.1.2  | [Plane Enterprise License](https://github.com/makeplane/plane-ee/blob/master/LICENSE.md) |
| Traefik          | 3.x     | [MIT](https://github.com/traefik/traefik/blob/master/LICENSE.md)         |
| PostgreSQL       | 15.7    | [PostgreSQL License](https://www.postgresql.org/about/licence/)          |
| Valkey (Redis)   | 7.2.11  | [BSD 3-Clause](https://github.com/valkey-io/valkey/blob/unstable/COPYING) |
| RabbitMQ         | 3.13.6  | [MPL 2.0](https://github.com/rabbitmq/rabbitmq-server/blob/main/LICENSE-MPL-RabbitMQ) |
| MinIO            | latest  | [AGPL 3.0](https://github.com/minio/minio/blob/master/LICENSE)           |

All of the above are always deployed by this stack, alongside Plane itself.

## Resources

This stack runs ~20 pods, including four stateful services with their own persistent
volumes. **Minimum: a single 4 vCPU / 8GB RAM node.** For a production-sized deployment
we recommend **3 nodes at 4 vCPU / 8GB RAM each**.

This minimum isn't a rough guess -- on a 2 vCPU / 4GB node, the first-install database
migration job alone (Postgres schema setup for a brand-new install) took **~30 minutes**
before the API became reachable, with everything else contending for the same limited
CPU. On 4 vCPU / 8GB it's substantially faster. If your cluster is smaller than this,
`deploy.sh` will still complete, but expect a long, CPU-starved wait before Plane comes
up on first install -- see [What to expect during install](#what-to-expect-during-install).

See the [chart's configuration reference](https://github.com/makeplane/helm-charts/blob/main/charts/plane-enterprise/README.md)
to right-size individual services (`services.<name>.cpuLimit` / `memoryLimit`) for your
workload.

# Getting Started

### Getting Started with DigitalOcean Kubernetes

As you get started with Kubernetes on DigitalOcean be sure to check out how to connect
to your cluster using `kubectl` and `doctl`:
https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/

Additional instructions are included in the DigitalOcean Kubernetes control panel:
https://cloud.digitalocean.com/kubernetes/clusters/

### What to expect during install

Whether you installed from the DigitalOcean portal's Marketplace tab or ran `deploy.sh`
yourself, there's no progress bar or "Plane is ready" notification -- Kubernetes 1-Click
Apps don't surface one, and the portal doesn't hand you an access link the way a Droplet
1-click would. You confirm it's up, and find its URL, with `kubectl` (see below).

What happens, in order, after `deploy.sh` runs:

1. Traefik is installed and gets a DigitalOcean LoadBalancer IP (~1-2 minutes).
2. Postgres, Valkey, RabbitMQ and MinIO come up, and Plane's database migration Job
   runs against a brand-new database. **This is the long pole.** On the minimum-spec 4
   vCPU / 8GB node it's a few minutes; on a smaller node, expect much longer -- on a 2
   vCPU / 4GB node in testing, this step alone took **~30 minutes**, with every other
   pod also contending for that same limited CPU. See [Resources](#resources).
3. The API pod stays at `0/1 Ready` for this entire window by design -- it's blocked on
   the migration Job finishing, not crashing. Once migrations complete, the API starts
   gunicorn and flips to `1/1 Ready` within seconds.
4. Every other service pod (web, space, admin, live, workers) comes up independently of
   the API and is usually `1/1 Ready` well before it.

### Confirm Plane is running

```bash
kubectl get pods -n traefik
kubectl get pods -n plane
```

All pods `Running`/`Completed` and the `api-wl` pod at `1/1 Ready` means it's fully up.
If `api-wl` is still `0/1`, check whether the migration Job has finished:

```bash
kubectl get jobs -n plane
```

A `Running` migration Job with `0/1` completions is normal and not stuck -- see timing
above.

### Domain and access

DigitalOcean's Kubernetes 1-Click flow gives `deploy.sh` no form field to collect a
domain, so on first install it derives a working hostname for you automatically from
Traefik's own LoadBalancer IP: `plane.<ip>.sslip.io`, using [sslip.io](https://sslip.io)'s
wildcard DNS (the same "no DNS setup needed" pattern Knative, Epinio and other Kubernetes
platforms default to -- `plane.<ip>.sslip.io` always resolves back to `<ip>`, nothing to
configure). Get that IP, then visit the app:

```bash
kubectl get svc traefik --namespace traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
# -> e.g. 129.212.245.103
```

Open `http://plane.<that-ip>.sslip.io` in your browser -- e.g.
`http://plane.129.212.245.103.sslip.io` -- and you'll land on Plane's workspace setup
flow.

To point your own domain at it instead, once you have terminal access to the cluster:

1. Get the Traefik LoadBalancer's external IP with the command above.
2. Create an `A` record for your domain pointing at that IP, then switch to it:

   ```bash
   DOMAIN_NAME=plane.example.com ./upgrade.sh
   ```

   This sets `license.licenseDomain`, which Plane's Traefik `IngressRoute` matches on --
   your domain will 404/not route until this step.

This stack serves over plain HTTP; see below for TLS.

### Adding a commercial license

Plane Enterprise runs on its free tier by default. To attach a paid plan license key
obtained from [prime.plane.so](https://prime.plane.so), see the `license` section of the
[chart README](https://github.com/makeplane/helm-charts/blob/main/charts/plane-enterprise/README.md).

### Customizing beyond this 1-click

`deploy.sh`/`upgrade.sh` deliberately expose only `DOMAIN_NAME` and `PLANE_VERSION` --
DigitalOcean's automated 1-Click flow can't pass in anything else, so there was no point
building more surface than that into the scripts. Everything else the chart supports is
still available; you just apply it yourself with `helm upgrade` once connected to your
cluster, referencing the [full chart README](https://github.com/makeplane/helm-charts/blob/main/charts/plane-enterprise/README.md)
for the exact keys. Common examples:

- **TLS** via cert-manager (`ssl.createIssuer`, `ssl.issuer`, etc. -- install cert-manager
  yourself first, e.g. DigitalOcean's own 1-Click for it, or bring your own certificate
  via `ssl.tls_secret_name`).
- **DigitalOcean Managed PostgreSQL/Valkey/OpenSearch** instead of the bundled
  StatefulSets (`services.postgres.local_setup: false` + `env.pgdb_remote_url`, and the
  equivalent `local_setup`/`*_remote_url` keys for Valkey and OpenSearch).
- **DigitalOcean Spaces** instead of bundled MinIO (`services.minio.local_setup: false`
  + `env.aws_access_key`/`aws_secret_access_key`/`aws_region`/`aws_s3_endpoint_url`,
  pointing at `https://<region>.digitaloceanspaces.com`).

RabbitMQ has no DigitalOcean managed equivalent, so it's always deployed from the
bundled StatefulSet regardless.

```bash
helm show values plane/plane-enterprise > my-values.yaml
# edit my-values.yaml
helm upgrade plane-app plane/plane-enterprise \
  --namespace plane \
  --reuse-values \
  -f my-values.yaml
```

`--reuse-values` matters here -- without it you'd drop the per-deployment secrets
`deploy.sh` generated on first install (see below).

### Secrets

`deploy.sh` generates random values for every secret the chart would otherwise ship with
a fixed default (Django's `SECRET_KEY`, the live-collaboration server secret, Silo's
HMAC/AES keys, and the bundled Postgres/RabbitMQ/MinIO/OpenSearch credentials) --
**only on first install**. Every later `deploy.sh` or `upgrade.sh` run passes
`--reuse-values` and does not regenerate them, since the running Postgres/RabbitMQ/MinIO
instances, and any sessions or tokens already signed with the old keys, depend on them
staying the same. You never need to handle these values yourself.

### Using a custom StorageClass

This stack pins `env.storageClass` to `do-block-storage`, DOKS's default. If you're
running a different or non-default StorageClass, pass
`--set env.storageClass=<your-storageclass-name>` with `--reuse-values` as shown above.

## Additional Resources

- [Plane documentation](https://developers.plane.so/)
- [Plane Helm chart reference](https://github.com/makeplane/helm-charts/blob/main/charts/plane-enterprise/README.md)
- [Plane on GitHub](https://github.com/makeplane/plane)

## Report bugs or ask questions

To report an issue with this 1-Click, or with the underlying Helm chart, open an issue
against [makeplane/helm-charts](https://github.com/makeplane/helm-charts/issues).
