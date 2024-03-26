FROM alpine:3.19.1

ARG TARGETARCH

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
RUN apk add --no-cache openssl bash

# Fixing https://security.alpinelinux.org/vuln/CVE-2024-0853
RUN wget -q https://github.com/curl/curl/releases/download/curl-8_6_0/curl-8.6.0.tar.gz &&\
    tar -xf curl-8.6.0.tar.gz &&\
    cd curl-8.6.0 &&\
    apk add openssl-dev g++ make autoconf libpsl-dev &&\
    ./configure --with-openssl &&\
    make && make install

# Install kubectl
RUN curl -LO https://dl.k8s.io/release/v1.28.8/bin/linux/${TARGETARCH}/kubectl &&\
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