# Pachyderm

### Prerequisites

- [`pachctl`](https://docs.pachyderm.com/latest/getting_started/local_installation/#install-pachctl), is the command-line tool that lets you interact with Pachyderm. It is a client-side tool and it will need to be installed on your local machine.
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/#kubectl), the Kubernetes command-line tool allows you to run commands against Kubernetes clusters.
- [`doctl`](https://docs.digitalocean.com/reference/doctl/how-to/install/), DigitalOcean's Client API tool supports most functionality found in the control panel. 

This installation is not designed to be a production environment. It is meant to help you learn and experiment quickly with Pachyderm.

If you wish to change the Helm Chart values you can find the full list [here](https://docs.pachyderm.com/latest/reference/helm_values/).

To connect kubectl to your cluster:  
- Find your `CLUSTER ID` inside your k8s cluster's overview page. You can find the list of your clusters [here](https://cloud.digitalocean.com/kubernetes/clusters).
- Run the following command: `doctl kubernetes cluster kubeconfig save <CLUSTER ID>`

Pachyderm will be installed in your k8s cluster in the `pachyderm` namespace.
You can view the pachyderm resources in your k8s cluster with the following command: `kubectl get all -n pachyderm`

The last step is to connect `pachctl` to your cluster. To do this, you will need to run three commands:  
- `pachctl config import-kube digitalocean --overwrite -n pachyderm`  
- `pachctl config set active-context digitalocean`
- Then in a new terminal window, run `pachctl port-forward`  

To test the connection, run `pachctl version`  
You should see the following output:  
```
COMPONENT           VERSION             
pachctl             2.0.8               
pachd               2.0.8      
```