# Mattermost Operator Stack

This stack deploys the Mattermost Operator and the dependencies that are needed.

## Getting Started after Installing Mattermost Operator

After you have downloaded your kubeconfig file, and are able to successfully connect
to your DigitalOcean Kubernetes cluster (see <https://cloud.digitalocean.com/kubernetes/clusters/>
if you haven’t connected to your cluster) follow the instructions below to start Mattermost.

#### NOTE: In order to operate properly, your Mattermost cluster requires at least 3 nodes each with 8GB of RAM and 4vCPUs

### Create your Mattermost Enterprise license secret

If you don't have a Mattermost Enterprise license you can register for a trial license
at <https://mattermost.com/trial/>

Create a file named `mattermost-license-secret.yaml` with the following content:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mattermost-license
type: Opqaue
stringData:
  license: %LICENSE_FILE_CONTENTS%
```

replacing `%LICENSE_FILE_CONTENTS%` with the content of your Mattermost license.

Apply it to your Mattermost cluster with:

```sh
kubectl apply -f mattermost-license-secret.yaml
```

### Create your Mattermost Installation manifest and apply it to the cluster

You can create a trial Mattermost cluster quickly and easily by using the following settings,
or alternatively if you have customized settings for your production deploy you can use those.

Create a file named `mattermost-installation.yaml` with the following content:

```yaml
apiVersion: mattermost.com/v1alpha1
kind: ClusterInstallation
metadata:
  name: mm-example-full
spec:
  size: 5000users
  image: mattermost/mattermost-enterprise-edition
  ingressName: mattermost.example.com
  useServiceLoadBalancer: true
  version: 5.15.0
  mattermostLicenseSecret: "mattermost-license"
  database:
    storageSize: 50Gi
  minio:
    storageSize: 50Gi
  elasticSearch:
    host: ""
    username: ""
    password: ""
```

You can read about customizations to your manifest at <https://docs.mattermost.com/install/install-kubernetes.html#deploy-a-mattermost-installation>

Apply it to your Mattermost cluster with:

```sh
kubectl create ns mattermost
```

followed by

```sh
kubectl apply -n mattermost -f mattermost-installation.yaml
```

Wait five minutes for the installation to complete, and then grab your LoadBalancer
External IP with the following:

```sh
kubectl get services
```

### Connect to Mattermost and get going

You'll see output similar to the following, and can visit the LoadBalancer EXTERNAL-IP in
your browser in order to get started with Mattermost:

```sh
NAME                           TYPE           CLUSTER-IP       EXTERNAL-IP       PORT(S)                      AGE
db-mysql                       ClusterIP      10.245.167.219   <none>            3306/TCP                     34m
db-mysql-master                ClusterIP      10.245.232.169   <none>            3306/TCP                     34m
kubernetes                     ClusterIP      10.245.0.1       <none>            443/TCP                      40m
mm-example-full                LoadBalancer   10.245.121.116   138.197.235.132   80:30265/TCP,443:32442/TCP   34m
mm-example-full-minio-hl-svc   ClusterIP      None             <none>            9000/TCP                     34m
mysql                          ClusterIP      None             <none>            3306/TCP,9125/TCP            34m
```

You can read more at <https://docs.mattermost.com/install/install-kubernetes.html>, including
resource scaling guidelines for the number of users your installation will support.

For more information about how to use please follow: <https://docs.mattermost.com/install/install-kubernetes.html>
