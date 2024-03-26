# Rancher/k3s cluster in docker containers

Learning how to deploy a simple 3 nodes (1 server and 2 agents) k3s cluster with rancher ui installed through a docker-compose.

## Environment

It's possible to define env variables in a .env file at the same level of the docker compose file.

ENV:
- **K3S_VERSION**: official rancher/k3s image version (default latest)
- **K3S_URL**: server url
- **K3S_TOKEN**: token to join the cluster (default secret)
- **K3S_KUBECONFIG_OUTPUT**: file where to store kube conf file
- **K3S_KUBECONFIG_MODE**: set permissions on kube conf file
- **RANCHER_ADMIN_PASSWORD**: admin password for the first access to Rancher UI (default admin)
- **RANCHER_DOMAIN**: valid DNS where to contact Rancher UI (default rancher.local)

## Docker containers:

With

```bash
docker compose up
```

4 are containers are going to go up:

- k3s-server
- k3s-agent-1
- k3s-agent-2
- rancherui-init

**k3s-server** and **k3s-agents** are going to form the cluster, **rancherui-init** it's like an init container that, when all the nodes and default pods are ready, will install cert-manager and rancher-ui in the cluster.