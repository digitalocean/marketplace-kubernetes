### Descrption
[KubeMQ](https://kubemq.io) is a Kubernetes native, enterprise-grade message queue broker.
High available, scalable and secured message broker designed to support high volume messaging with low latency and efficient memory usage. Supports all messaging and queuing patterns with super easy one-minute deployment on cloud, on-premises or hybrid infrastructure. Delivered in a lightweight, production ready statefulset containers.

KubeMQ can save your organization time and money by integrating development and operations workflows into a unified system. Its ease of use and DevOps friendliness minimizes the need for dedicated experts and accelerate the development and production cycles. Integrated with a range of best of breed cloud-native applications.
You can use KubeMQ for free. Following the initial 7 days quick deployment, you'll need a [free KubeMQ license key](https://account.kubemq.io/login/register).  
For KubeMQ enterprise service (including: on-boarding package, open source, integration, customization, training & enterprise support), please contact us directly: info@kubemq.io .
You can find out more about KubeMQ at https://www.kubemq.io.

### Step 1 - Point to your Cluster

Before we can do anything, we need to ensure you have access to a Kubernetes cluster you have deployed before

1. Get list of your clusters
```bash
doctl k8s cluster list
```

2. Save your kube config to your kubectl config file
```bash
doctl k8s cluster kubeconfig save <your created cluster name>
```

3. Get your context list and look for your cluster context name
```bash
kubectl config get-contexts
```

4. Switch to desired context

```bash
kubectl config set-context <your-cluster-context-name>
```

### Step 2 - Get KubeMQ CLI - kubemqctl

Kubemqctl is a CLI (Command Line Interface) tool to deploy and manage KubeMQ clusters.

#### macOS / Linux

```bash
curl -sL https://get.kubemq.io/install | sh 
```
#### Windows

##### Option 1:

- [Download the latest kubemqctl.exe](https://github.com/kubemq-io/kubemqctl/releases/download/latest/kubemqctl.exe).
- Place the file under e.g. `C:\Program Files\kubemqctl\kubemqctl.exe`
- Add that directory to your system path to access it from any command prompt

##### Option 2:
Run in PowerShell as administrator:

```powershell
New-Item -ItemType Directory 'C:\Program Files\kubemqctl'
Invoke-WebRequest https://github.com/kubemq-io/kubemqctl/releases/download/latest/kubemqctl.exe -OutFile 'C:\Program Files\kubemqctl\kubemqctl.exe'
[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine) + ';C:\Program Files\kubemqctl', [EnvironmentVariableTarget]::Machine)
$env:Path += ';C:\Program Files\kubemqctl'
```


### Step 3 - Send 'hello-world'

After you have created a KubeMQ cluster, you can send hello-world message to q1 queue channel.

``` bash
kubemqctl queue send q1 hello-world
```

### Step 4 - Get 'hello-world'

After you have sent a message to q1 queue channel, you can retrieve the message like this:

``` bash
kubemqctl queue receive q1
```

