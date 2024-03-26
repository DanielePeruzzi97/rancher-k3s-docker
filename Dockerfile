FROM alpine:3.19.1

# Set environment variables
ENV USER=kube
ENV GROUP=kube
ENV HOME=/home/kube
ENV KUBECONFIG_DIR=${HOME}/.kube
ENV KUBECONFIG=${KUBECONFIG_DIR}/config

# Update and upgrade alpine to mitigate vulnerabilities
RUN apk update && apk upgrade

# Create non-root user and group
RUN addgroup -S ${GROUP} && adduser -D -h ${HOME} -S ${USER} -G ${GROUP} &&\
    mkdir -p ${KUBECONFIG_DIR} && chown -R ${USER}:${GROUP} ${KUBECONFIG_DIR}

# Install dependencies (openssl and bash are required for helm)
RUN apk add --no-cache curl openssl bash

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" &&\
    mv kubectl /usr/local/bin/kubectl &&\
    chmod +x /usr/local/bin/kubectl

# Install helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh

# Volume to store kubeconfig
VOLUME /output

# Environment variable to connect to k3s server
ENV K3S_URL=
# Environment variables to configure Rancher UI access
ENV RANCHER_ADMIN_PASSWORD=admin
ENV RANCHER_DOMAIN=rancher.local

# Copy entrypoint script to execute kubectl and helm commands
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Change to non-root user
USER ${USER}

ENTRYPOINT [ "/entrypoint.sh" ]