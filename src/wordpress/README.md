# WIP
Need to add a complete description and getting started section.

## Getting Started
```
1. Get the WordPress URL:

  NOTE: It may take a few minutes for the LoadBalancer IP to be available.
        Watch the status with: 'kubectl get svc --namespace default -w click-wordpress'
  export SERVICE_IP=$(kubectl get svc --namespace default click-wordpress --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
  echo "WordPress URL: http://$SERVICE_IP/"
  echo "WordPress Admin URL: http://$SERVICE_IP/admin"

2. Login with the following credentials to see your blog

  echo Username: user
  echo Password: $(kubectl get secret --namespace default click-wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)
  ```
