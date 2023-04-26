# Getting started

The minimum cluster size is 2 nodes (2 CPU 2Gi each).

## Features
🔍 Search Infrastructure: Resoto maps out your cloud infrastructure in a [graph](https://resoto.com/docs/concepts/graph) and provides a simple [search syntax](https://resoto.com/docs/concepts/search).

📊 Generate Reports: Resoto keeps track of and reports infrastructure changes over time, making it easy to [audit resource usage and cleanup](https://resoto.com/docs/concepts/cloud-data-sync).

🤖 Automate Tasks: Tedious tasks like rule enforcement, resource tagging, and cleanup can be [automated using jobs](https://resoto.com/docs/concepts/automation).


## Deploying and accessing Resoto

1. Your application will be hosted at a service IP. Run these commands to get your installation location:
    ```bash
    export SERVICE_ADDRESS=$(kubectl get --namespace resoto service resoto-resotocore -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
    echo "Visit https://$SERVICE_ADDRESS:8900 to use Resoto."
    ```
   You should now be able to navigate to Resoto at the location printed out to your terminal!
   Please note: the certificate is self-signed, so you must accept the certificate warning in your browser.

   We recommend registering a domain name and creating an Ingress with a valid TLS certificate.

2. A private shared key (PSK) has been created to access your installation. You can find it in the `resoto-psk` secret:
    ```bash
    kubectl get --namespace resoto secret resoto-psk -o jsonpath="{.data.psk}" | base64 -d
    ```
   This key is used to authenticate with the Resoto API.

3. The UI will guide you through the rest of the setup process.
   You can find documentation at [Resoto Docs](https://resoto.com/docs/getting-started)

## Contact
If you have any questions, feel free to [join our Discord](https://discord.gg/someengineering) or [open a GitHub issue](https://github.com/someengineering/resoto/issues/new).
