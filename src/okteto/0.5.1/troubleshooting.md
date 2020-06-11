# Troubleshooting your installation

### `Error: release my-release failed: customresourcedefinitions.apiextensions.k8s.io "orders.certmanager.k8s.io" already exists`

This happens when cert-managers CRDs are already created, or if there's already another Okteto or cert-manager installation in your cluster. You need to delete the existing installations in order to proceed. 
If you keep getting the error after deleting the existing installations, delete the CRDs directly by running the following command: `kubectl delete -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml`

### Certificate doesn't get validated
Get the status of your ceritificate by running `kubectl get certificate default-ssl-certificate -oyaml`

Check the logs of the cert-manager pod by running `kubectl logs deployment/appliance-cert-manager`.

`"error"="GoogleCloud API call failed: googleapi: Error 403: Request had insufficient authentication scopes., forbidden"`
This happens when your cluster doesn't have the right permissions to use CloudDNS.  Either create a specific account for this, or add the 