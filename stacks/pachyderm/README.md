<!-- SPDX-FileCopyrightText: © 2022 Pachyderm, Inc. <info@pachyderm.com> -->
# Pachyderm
### Prerequisites

*Please install the following:*

- [`pachctl`](<https://docs.pachyderm.com/latest/getting_started/local_installation/#install-pachctl>), is the command-line tool that lets you interact with Pachyderm. It is a client-side tool and it will need to be installed on your local machine.
- [`kubectl`](<https://kubernetes.io/docs/tasks/tools/#kubectl>), the Kubernetes command-line tool allows you to run commands against Kubernetes clusters.
- [`doctl`](<https://docs.digitalocean.com/reference/doctl/how-to/install/>), DigitalOcean's Client API tool supports most functionality found in the control panel.

*If you wish to customize your pachyderm configuration you will need to install [Helm](<https://helm.sh/docs/intro/install/#helm>). You can find the full list of Helm Chart values [here](<https://docs.pachyderm.com/latest/reference/helm_values/>). To upgrade pachyderm with your new values follow the instructions [here](<https://docs.pachyderm.com/latest/deploy-manage/deploy/helm_install/#upgrade-pachyderms-helm-chart>).*

#### This installation is **NOT** designed to be a production environment. It is meant to help you learn and experiment quickly with Pachyderm.

---

To connect `kubectl` to your Kubernetes cluster:

- Follow the instructions found in step 2 (Connecting to Kubernetes) of the Getting Started section for your Kubernetes cluster.

    OR

- Find your Cluster ID and run the following command:

`doctl kubernetes cluster kubeconfig save &amp;lt;Insert Cluster ID Here&amp;gt;`

Pachyderm will already be installed in your cluster in the `pachyderm` namespace.

To confirm run:

`kubectl get pods -n pachyderm`

Your output should look like this:

```
NAME                                         READY   STATUS    RESTARTS   AGE
console-d56d7b7f6-j5lvc                      1/1     Running   0          10m
etcd-0                                       1/1     Running   0          10m
pachd-76f7d5455-jk2lj                        1/1     Running   0          10m
pachyderm-kube-event-tail-54f6759474-tnf8q   1/1     Running   0          10m
pachyderm-loki-0                             1/1     Running   0          10m
pachyderm-promtail-7drcc                     1/1     Running   0          10m
pachyderm-promtail-k846r                     1/1     Running   0          10m
pachyderm-promtail-ltdx4                     1/1     Running   0          10m
pachyderm-proxy-fff6dc868-qcxk4              1/1     Running   0          10m
pg-bouncer-57869fc46c-pgqz5                  1/1     Running   0          10m
postgres-0                                   1/1     Running   0          10m
```

The last step is to connect `pachctl` to your cluster. To do this, you will need to run three commands:

`kubectl get service pachyderm-proxy -n pachyderm`

Once an IP address is listed under `EXTERNAL-IP`, run the following command using that IP:

`echo '{"pachd_address": "grpc://<IP ADDRESS HERE>:80"}' |pachctl config set context digitalocean`

To verify your connection run: `pachctl version`

You should see the following output:

```
COMPONENT           VERSION             
pachctl             2.4.4               
pachd               2.4.4
```

You can also access the web interface at `http://<IP ADDRESS HERE>`

---

## You are now ready to start the [Beginner Tutorial](<https://docs.pachyderm.com/latest/getting_started/beginner_tutorial/>)!

