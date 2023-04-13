# Description 

FusionAuth is a modern platform for Customer Identity and Access Management (CIAM). FusionAuth provides APIs and a responsive web user interface to support login, registration, localized email, multi-factor authentication, reporting and much more.

## Software included

| Package       | Application Version | License                                                       |
|---------------|---------------------|---------------------------------------------------------------|
| FusionAuth    | 1.42.0              | [License](https://fusionauth.io/license)                      |

### Resources
This stack was successfully tested with a Digital Ocean Kubernetes Cluster with 6 GB RAM and 4 vCPUs.
### FusionAuth running at...
Once the FusionAuth stack is installed in the DigitalOcean 1-Click Apps Marketplace you should:
1. Run `helm list -n fusionauth` to confirm stack was deployed. You should have 3 deployments: db, fusionauth, search.
2. Check running pods and their status with:  kubectl get pods -n fusionauth
3. Connect to your cluster via the command line. 
4. To visit FusionAuth, enter the following into the command line:
    export SERVICE_IP=$(kubectl get svc --namespace fusionauth fusionauth -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    echo Visit http://$SERVICE_IP:9011/ to access the FusionAuth console.
       



## Report bugs or ask questions

To report an issue, or request a feature: [FusionAuth Helm Chart Issue](https://github.com/FusionAuth/charts/issues).

Document a bug or feature request for FusionAuth: [FusionAuth/fusionauth-issues](https://github.com/FusionAuth/fusionauth-issues/issues)
