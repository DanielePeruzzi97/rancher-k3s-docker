FROM alpine:3.19.1

# Install dependencies (openssl and bash are required for helm)
RUN apk add --no-cache curl openssl bash sed

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" &&\
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh

# Copy kubeconfig exposed by the rancher/k3s server container
# COPY ./kubeconfig.yaml /root/.kube/config

VOLUME /root/.kube/
ENV K3S_URL="https://server:6443"
# RUN sed -i "s|server:.*|server: $K3S_URL|g" /root/.kube/config

# Copy entrypoint script to execute kubectl and helm commands
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]