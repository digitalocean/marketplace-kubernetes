# Description

[Otomi](https://otomi.io/) is a self-hosted PaaS for kubernetes that integrates several technologies found in the CNCF landscape into a single installable package to provide direct value to developers.

Otomi is 100% open source and community supported, and can be found at [redkubes/otomi-core](https://github.com/redkubes/otomi-core).

**Notes:**

- This stack requires a minimum configuration of 4 nodes at the $0.13/hour plan (2.5GB memory/2 vCPUs)

## Software included

| Package               | Application Version   |License                                                                                    |
| ---| ---- | ------------- |
| otomi | [v0.16.3](https://github.com/redkubes/otomi-core/releases/tag/v0.16.3) | [Apache 2.0](https://github.com/redkubes/otomi-core/blob/main/LICENSE) |

## Getting Started

### How to Connect to Your Cluster

Follow these [instructions](https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/) to connect to your cluster with `kubectl` and `doctl`.

### Confirming that Otomi is Running

First, check if the Otomi installation was successful by running the command below:

```bash
kubectl get job otomi -w
```

The output looks similar to the following:

```text
NAME    COMPLETIONS   DURATION   AGE
otomi   1/1           14m        14m
```
  
Next, check the installer job logs to get the otomi console `url` and `credentials` by running the following command:

```bash
kubectl logs jobs/otomi -n default --tail=7
```

The output looks similar to the following:

```bash
########################################################################################################################################
#
#  To start using Otomi, go to https://otomi.134.209.133.239.nip.io and sign in to the web console
#  with username "otomi-admin" and password "OTzVCbJbvIN1T0LIij4U".
#  Then activate Drone. For more information see: https://otomi.io/docs/installation/activation/
#
########################################################################################################################################
```
  
### Accessing Otomi console

- Sign into the otomi web console `url` using the `credentials` found in the installer job logs.

<!-- <p align="center"><img src="https://github.com/redkubes/marketplace-kubernetes/blob/main/img/otomi-console-login.png/?raw=true" width="100%" align="center" alt="otomi console login"></p> -->

  <img src="./img/otomi-console-login.png" alt="otomi console login" width="1080" height="570" align="center"/>

- Add the auto generated CA to your keychain/credential manager (optional)

<img src="./img/download-ca.png" alt="download ca" width="1080" height="570"/>

```bash
NOTE:
# To prevent you from clicking away lots of security warnings in your browser, you can add the generated CA to your keychain/credential manager:
# Since we install Otomi without proving a custom CA or using LetsEncrypt, the installer generated a CA which is not trusted on your local machine.
```

- In the left menu of the console, click on "Download CA"
- Double click the downloaded CA.crt or add the CA to your keychain on your mac using the following command:
  
  ```bash
  # On Mac
  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ~/Downloads/ca.crt
  # Restart the browser 
  ```  

  ```powershell
  # On Windows(PowerShell - Run as Administrator)
  # Use certutil:
  certutil.exe -addstore root <downloaded cert path>
  # Or 
  Import-Certificate -FilePath "<downloaded cert path>" -CertStoreLocation Cert:\LocalMachine\Root
  # Restart the browser 
  ```

### Post-install configurations

- In the side menu of Otomi Console under `Platform`, select `Apps` and click on the **Drone** app
- Click on the `play` button in the top right. A new tab will open for Drone
- Sign in locally with as `otomi-admin` and the password provided in the logs of the installer job.
- Click on `Authorize Application`
- Click on `Submit on the Complete your Drone Registration page. You don't need to fill in your Email, Full Name or Company Name if you don't want to
- Click on the `otomi/values` repository
- Click on `+ Activate Repository`

<img src="./img/otomi-drone-activate.gif" alt="activate drone" width="1080" height="570"/>

### Upgrading Otomi

To be done

### Uninstalling Otomi

To be done

### Additional Resources

- [Workshops: Explore Otomi through series of hands-on labs](https://github.com/redkubes/workshops)
- [Otomi Documentation](https://otomi.io/docs/installation/)
