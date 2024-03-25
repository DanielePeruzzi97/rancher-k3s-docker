FROM alpine:3.19.1

# Install dependencies (openssl and bash are required for helm)
RUN apk add --no-cache curl openssl bash

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" &&\
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh

# Volume to store kubeconfig
VOLUME /root/.kube/

# Environment variable to connect to k3s server
ENV K3S_URL=
# Environment variables to configure Rancher UI access
ENV RANCHER_ADMIN_PASSWORD=
ENV RANCHER_DOMAIN=

# Copy entrypoint script to execute kubectl and helm commands
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]