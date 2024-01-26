# Atm0s Media Server Stack: Decentralized Ultra-Low Latency Streaming Server

A decentralized media server designed to handle media streaming on a global scale, making it suitable for large-scale applications but with minimal cost. It is designed with [SAN-I/O](https://sans-io.readthedocs.io/) in mind.

For a deep dive into the technical aspects of network architecture, please refer to our [Smart-Routing](https://github.com/8xFF/atm0s-sdn/blob/master/docs/smart_routing.md)

[<img src="https://img.youtube.com/vi/QF8ZJq9xuSU/hqdefault.jpg"
/>](https://www.youtube.com/embed/QF8ZJq9xuSU)

(Above is a demo video of the version used by Bluesea Network)

## Features

- 🚀 Powered by Rust with memory safety and performance.
- High availability by being fully decentralized, with no central controller.
- 🛰️ Multi-zone support, high scalability.
- Support encodings: H264, Vp8, Vp9, H265 (Coming soon), AV1 (Coming soon)
- Cross-platform: Linux, macOS, Windows.
- Decentralized WebRTC SFU (Selective Forwarding Unit)
- Modern, full-featured client SDKs
  - [x] [Vanilla JavaScript](https://github.com/8xFF/atm0s-media-sdk-js)
  - [x] [Rust](WIP)
  - [x] [React](https://github.com/8xFF/atm0s-media-sdk-react)
  - [x] [React Native](WIP)
  - [ ] Flutter
  - [ ] iOS Native
  - [ ] Android Native
- Easy to deploy: single binary, Docker, or Kubernetes
- Advanced features including:
  - [x] Audio Mix-Minus (WIP)
  - [x] Simulcast/SVC
  - [x] SFU
  - [x] SFU Cascading (each stream is a global PubSub channel, similar to [Cloudflare interconnected network](https://blog.cloudflare.com/announcing-cloudflare-calls/))
  - [ ] Recording
  - [x] RTMP
  - [x] SIP (WIP)
  - [x] WebRTC
  - [x] Whip/Whep

## Software Included

| Package         | Server Version | Helm Chart Version |
| --------------- | -------------- | ------------------ |
| Webrtc          | 0.1.2          | 0.1.0              |
| RTMP            | 0.1.2          | 0.1.0              |
| Token Generator | 0.1.2          | 0.1.0              |
| Gateway         | 0.1.2          | 0.1.0              |
| Connector       | 0.1.2          | 0.1.0              |
| Nats            | 2.10           | 0.1.0              |

## Prerequisites

1. Kubernetes >= 1.23+
2. Access to your cluster with kubectl and helm

## Getting Started

### Setup you host

By default the cluster will be receiving request from your Ingress Controller IP. To setup your host:

- You need to have `kubectl` and `helm` setup.
- Get the default `values.yaml` here: https://github.com/8xFF/helm/blob/main/charts/atm0s-media/values.yaml
- Update the `gateway.host` property with your hostname.
- Run `helm upgrade -f <path/to/values.yaml> atm0s-media-stack 8xff/atm0s-media-stack -n atm0s-media`

### Usage

Due to URL Rewrite, the every request to gateway or authentication will need to be prefixed with `/gateway` and `/auth` respectively.
For more detail: https://github.com/8xFF/atm0s-media-server

## Firewalls

For the stack's node to communicate with each others, the pods will be using `hostNetwork`, so you will need to set some Inbound TCP and UDP Rules for each of the service's ports you've enabled.

## Getting Started with DigitalOcean Kubernetes

If you have problems connecting to your DigitalOcean Kuberenetes cluster using `kubectl` see:
https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/

Additional instructions are included in the DigitalOcean Kubernetes control panel:
https://cloud.digitalocean.com/kubernetes/clusters/

For further supports, you can join our Discord Channel: https://discord.gg/9CrAZUrHse
