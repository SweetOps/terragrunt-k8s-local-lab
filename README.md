[![CI](https://github.com/SweetOps/terragrunt-k8s-local-lab/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/SweetOps/terragrunt-k8s-local-lab/actions/workflows/ci.yml)

# Setup on macOS

This guide will walk you through setting up a local Kubernetes cluster with custom DNS resolution, TLS certificates, and Docker network connectivity on macOS.

---

## 🛠 Prerequisites

Install the following tools using Homebrew:

```sh
brew install dnsmasq mkcert chipmk/tap/docker-mac-net-connect
```

---

## 📜 Step 1: Create Local TLS Certificates

```sh
CA_CERTS_FOLDER=$(pwd)/.certs
CAROOT=${CA_CERTS_FOLDER}
mkdir -p ${CA_CERTS_FOLDER}
mkcert -install
```

This will:

* Create a `.certs` directory in your current working directory
* Set `CAROOT` to that directory
* Generate a local Certificate Authority and install it into your system trust store

---

## 🌐 Step 2: Set Up DNS Resolution

Configure `dnsmasq` to resolve development domains to your local network IP:

```sh
mkdir -pv $(brew --prefix)/etc/
echo 'address=/.k8s.dev.local/172.18.0.200' >> $(brew --prefix)/etc/dnsmasq.conf
```

Start the `dnsmasq` service:

```sh
sudo brew services start dnsmasq
```

This allows domain names like `*.dev.local` and `*.k8s.dev.local` to resolve to `172.18.0.200`.

---

## 🚓 Step 3: Start Docker Network Proxy

Start the `docker-mac-net-connect` service to enable container access to the host network:

```sh
sudo brew services start docker-mac-net-connect
```

---

## 🚀 Deployment

The deployment process consists of two stages:

### 1. Cluster Creation and Cilium Bootstrapping

Run the following to create the Kubernetes cluster and install Cilium:

```sh
terragrunt run validate --feature initial_apply=true --all
```

### 2. Deploy Kubernetes Add-ons

Once the cluster is ready, deploy the required add-ons:

```sh
terragrunt run validate --all
```
