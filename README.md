# Rancher/k3s cluster in docker containers

## How to use

Download the docker-compose.yml.

Then:

```
docker compose up
```

the operation can take a while.

To check the pods enter in the k3s-server container and run:
```
watch kubectl get pods --all-namespaces
```

## Environment

It's possible to define env variables in a .env file at the same level of the docker compose file.

ENV:
- **K3S_VERSION**: official rancher/k3s image version (default "v1.27.12-k3s1")
- **K3S_URL**: server url (obligatory)
- **K3S_TOKEN**: token to join the cluster (default "secret")
- **K3S_KUBECONFIG_OUTPUT**: file where to store kube conf file
- **K3S_KUBECONFIG_MODE**: set permissions on kube conf file
- **RANCHER_ADMIN_PASSWORD**: admin password for the first access to Rancher UI (default "admin")
- **RANCHER_DOMAIN**: valid DNS where to contact Rancher UI (default "rancher.local")

## Docker containers:

4 containers are going to go up:

- k3s-server
- k3s-agent-1
- k3s-agent-2
- rancherui-init

**k3s-server** and **k3s-agents** are going to form the cluster, **rancherui-init** it's an init container that, when all the nodes and default pods are ready, will install cert-manager and rancher-ui in the cluster without privileged flag.

## TODO

CVE (3M) fix to implement for **sysperu/kubectl:main** image:

- [ ] CVE-2020-8552 k8s.io/apiserver 0.29.0
- [ ] CVE-2024-24786⁠ google.golang.org/protobuf 1.31.0
- [ ] CVE-2024-24557 github.com/docker/docker 24.0.7+incompatible

All regarding /usr/local/bin/helm

CVE (2H and 8M) fix to implement for **rancher/k3s:v1.27.12-k3s1** image.

Containers:
- [ ] Implement rootless mode in k3s docker containers
- [ ] Find a way to remove privileged flag in the compose file

Regarding the last point, the flag privileged seems necessary in a container in container environament.
Even if maybe possible to remove the flag mounting hosts directories inside k3s containers, as cgroup and kernel modules directories in rw mode.
Also it's possible to have a more precise control adding cap_add options in the docker compose file.

Thats a way to reproduce the same privileged flag condition without using it.

```mermaid
C4Context

    title Docker Containers Architecture

    Person(user, "User")

    System_Boundary(host_machine, "Host Machine"){
        Container_Boundary(docker, "Docker Environment", "Privileged to access kernel module and fs on the host machine"){
            Container_Boundary(docker_cluster, "docker-cluster"){    
                Container(k3s-server, "k3s-server", "k3s cluster manager node", "6443, 80, 443")
                Container(k3s-agent-1, "k3s-agent-1", "k3s cluster worker node")
                Container(k3s-agent-2, "k3s-agent-2", "k3s cluster worker node")
            }
            Container_Boundary(docker_init, "init-container"){
                Container_Ext(rancherui-init, "rancherui-init", "rancherui init container", "Install rancherui in k3s cluster, then kill itself")
            }
        }
    }

    Rel(user, k3s-server, "http/https")
    BiRel(k3s-server, k3s-agent-1, "k3s_net")
    BiRel(k3s-server, k3s-agent-2, "k3s_net")
    Rel(rancherui-init, k3s-server, "k3s_net")

    UpdateRelStyle(user, k3s-server, $textColor="white", $lineColor="white", $offsetY="10", $offsetX="30")
    UpdateRelStyle(k3s-server, k3s-agent-1, $textColor="white", $lineColor="white", $offsetY="10", $offsetX="-10")
    UpdateRelStyle(k3s-server, k3s-agent-2, $textColor="white", $lineColor="white", $offsetY="10", $offsetX="10")
    UpdateRelStyle(rancherui-init, k3s-server, $textColor="white", $lineColor="white", $offsetY="10", $offsetX="150")

```