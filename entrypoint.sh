#!/bin/bash

function updateKubeConfig(){
    cp /output/kubeconfig.yaml /root/.kube/config
    sed -i "s|server:.*|server: $K3S_URL|g" /root/.kube/config
}

function installCertManager(){
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    helm install cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --create-namespace \
        --set installCRDs=true
}

function installRancherUI(){
    helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
    kubectl create namespace cattle-system
    helm install rancher rancher-stable/rancher \
        --namespace cattle-system \
        --set hostname=rancher.local \
        --set bootstrapPassword=admin
}

updateKubeConfig
installCertManager
installRancherUI