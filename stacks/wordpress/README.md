# WordPress

1. Get the WordPress URL by running these commands:

    NOTE: It may take a few minutes for the LoadBalancer IP to be available.
        Watch the status with: `kubectl get svc --namespace wordpress -w wordpress`

    ```bash
    export SERVICE_IP=$(kubectl get svc --namespace wordpress wordpress --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
    echo "WordPress URL: http://$SERVICE_IP/"
    echo "WordPress Admin URL: http://$SERVICE_IP/admin"
    ```

2. Open a browser and access WordPress using the obtained URL.

3. Login with the following credentials below to see your blog:

    ```bash
    echo Username: user
    echo Password: $(kubectl get secret --namespace wordpress wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)
    ```
