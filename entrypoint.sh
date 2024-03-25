#!/bin/bash

function checkFileChanged(){
    echo "Checking if file $1 has been changed"
    checksum=$(cksum $1 | awk '{ print $1 }')
    while true; do
        new_checksum=$(cksum $1 | awk '{ print $1 }')
        if [ "$checksum" != "$new_checksum" ]; then
            echo "File $1 has been changed"
            break
        fi
    done
}

function waitForK3SServer(){
    checkFileChanged /output/config
    updateKubeConfig
    echo "Waiting for k3s server to be ready..."
    until kubectl get nodes;
    do
        echo "Waiting for k3s server to be ready"
        sleep 5
    done
}

# https://stackoverflow.com/questions/75641788/bash-kubectl-wait-till-all-pods-are-in-running
function waitForPods(){
    echo "Waiting for all pods to be in Running or Completed or Terminated state..."
    # kubectl wait pod --all --for=condition=Running --all-namespaces
    while true
    do
        pods_count=$(kubectl get pods --all-namespaces | grep -cE "Running|Completed|Terminating")
        total_pods_count=$(kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.status.phase}{"\n"}{end}' | wc -l)

        if [ "$pods_count" -eq "$total_pods_count" ]; then
            echo "All pods are ready"
            break
        else
            echo "Waiting for all pods to be ready"
            sleep 10
        fi
    done
}

function updateKubeConfig(){
    echo "Updating kubeconfig to connect to k3s server"
    cp /output/config /root/.kube/config
    sed -i "s|server:.*|server: $K3S_URL|g" /root/.kube/config
    chmod 600 /root/.kube/config
}

function installCertManager(){
    waitForPods
    echo "Installing cert-manager through helm"
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    helm install cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --create-namespace \
        --set installCRDs=true
}

function installRancherUI(){
    waitForPods
    echo "Installing Rancher UI through helm"
    helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
    kubectl create namespace cattle-system
    helm install rancher rancher-stable/rancher \
        --namespace cattle-system \
        --set hostname=${RANCHER_DOMAIN} \
        --set bootstrapPassword=${RANCHER_ADMIN_PASSWORD}
}

waitForK3SServer
sleep 10
installCertManager
sleep 10
installRancherUI
exit 0