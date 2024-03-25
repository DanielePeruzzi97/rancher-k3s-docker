#!/bin/bash

# https://stackoverflow.com/questions/75641788/bash-kubectl-wait-till-all-pods-are-in-running
function waitForPods(){
    echo "Waiting for all pods to be in Running or Completed or Terminated state..."
    # kubectl wait pod --all --for=condition=Running --all-namespaces
    pods_count=$(kubectl get pods --all-namespaces | grep -c "Running|Completed|Terminated")

    while [ $pods_count -ne $(kubectl get pods --all-namespaces | grep -c "")]
    do
     echo "waiting for all pods to be ready"
     sleep 10
    done

    echo "All pods are ready"
}

function updateKubeConfig(){
    echo "Updating kubeconfig to connect to k3s server"
    cp /output/kubeconfig.yaml /root/.kube/config
    sed -i "s|server:.*|server: $K3S_URL|g" /root/.kube/config
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

updateKubeConfig
installCertManager
installRancherUI