#!/bin/bash

# Export KUBECONFIG path
# export KUBECONFIG=/etc/rancher/rke2/config.yaml

# Step 1: Generate a new TLS certificate with the correct SAN

# Define certificate details
CERT_DIR="/etc/rancher/rke2/certs"
CERT_NAME="server"
CERT_KEY="${CERT_DIR}/${CERT_NAME}.key"
CERT_CSR="${CERT_DIR}/${CERT_NAME}.csr"
CERT_CRT="${CERT_DIR}/${CERT_NAME}.crt"
CA_CRT="${CERT_DIR}/ca.crt"
CA_KEY="${CERT_DIR}/ca.key"
SAN="DNS:fqdn-control.udev.local,DNS:ingress.local"

# Create /usr/local/share/ca-certificates/ directory if it doesn't exist
CA_CERT_DIR="/usr/local/share/ca-certificates"
sudo mkdir -p ${CA_CERT_DIR}

# Copy certificates to the CA_CERT_DIR
sudo cp ${CA_CRT} ${CA_CERT_DIR}/
sudo cp ${CERT_CRT} ${CA_CERT_DIR}/

# Update the CA certificates in the system
sudo update-ca-certificates

# Generate private key
openssl genpkey -algorithm RSA -out $CERT_KEY -pkeyopt rsa_keygen_bits:2048

# Create a Certificate Signing Request (CSR) with the proper SAN
openssl req -new -key $CERT_KEY -out $CERT_CSR -subj "/CN=fqdn-control.udev.local" \
    -addext "subjectAltName=${SAN}"

# Sign the CSR with the CA to get the certificate
openssl x509 -req -in $CERT_CSR -CA $CA_CRT -CAkey $CA_KEY -CAcreateserial \
    -out $CERT_CRT -days 365 -extensions v3_req -extfile <(cat <<-EOF
[ v3_req ]
subjectAltName = DNS:${SAN}
EOF
)

# Step 2: Update Kubernetes configuration with the new certificate

# Set cluster configuration for admin.kubeconfig
kubectl config set-cluster fqdn-control.udev.local \
  --certificate-authority=${CA_CRT} \
  --embed-certs=true \
  --server=https://fqdn-control.udev.local:6443 \
  --kubeconfig=/etc/rancher/rke2/admin.kubeconfig

kubectl config set-credentials system:node:sewol-master-vm-01.udev.local \
  --client-certificate=${CERT_CRT} \
  --client-key=${CERT_KEY} \
  --embed-certs=true \
  --kubeconfig=/etc/rancher/rke2/admin.kubeconfig

kubectl config set-context default \
  --cluster=fqdn-control.udev.local \
  --user=system:node:sewol-master-vm-01.udev.local \
  --kubeconfig=/etc/rancher/rke2/admin.kubeconfig

kubectl config use-context default \
  --kubeconfig=/etc/rancher/rke2/admin.kubeconfig

# Set cluster configuration for kube-proxy.kubeconfig
kubectl config set-cluster fqdn-control.udev.local \
  --certificate-authority=${CA_CRT} \
  --embed-certs=true \
  --server=https://fqdn-control.udev.local:6443 \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
  --client-certificate=${CERT_CRT} \
  --client-key=${CERT_KEY} \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=fqdn-control.udev.local \
  --user=system:kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default \
  --kubeconfig=kube-proxy.kubeconfig

# Set cluster configuration for kube-controller-manager.kubeconfig
kubectl config set-cluster fqdn-control.udev.local \
  --certificate-authority=${CA_CRT} \
  --embed-certs=true \
  --server=https://fqdn-control.udev.local:6443 \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=${CERT_CRT} \
  --client-key=${CERT_KEY} \
  --embed-certs=true \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-context default \
  --cluster=fqdn-control.udev.local \
  --user=system:kube-controller-manager \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config use-context default \
  --kubeconfig=kube-controller-manager.kubeconfig

# Set cluster configuration for kube-scheduler.kubeconfig
kubectl config set-cluster fqdn-control.udev.local \
  --certificate-authority=${CA_CRT} \
  --embed-certs=true \
  --server=https://fqdn-control.udev.local:6443 \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=${CERT_CRT} \
  --client-key=${CERT_KEY} \
  --embed-certs=true \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-context default \
  --cluster=fqdn-control.udev.local \
  --user=system:kube-scheduler \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config use-context default \
  --kubeconfig=kube-scheduler.kubeconfig

# Set cluster configuration for admin.kubeconfig with localhost server
kubectl config set-cluster fqdn-control.udev.local \
  --certificate-authority=${CA_CRT} \
  --embed-certs=true \
  --server=https://fqdn-control.udev.local:6443 \
  --kubeconfig=admin.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=${CERT_CRT} \
  --client-key=${CERT_KEY} \
  --embed-certs=true \
  --kubeconfig=admin.kubeconfig

kubectl config set-context default \
  --cluster=fqdn-control.udev.local \
  --user=admin \
  --kubeconfig=admin.kubeconfig

kubectl config use-context default \
  --kubeconfig=admin.kubeconfig

# Encryption key for Kubernetes secret
export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

envsubst < configs/encryption-config.yaml \
  > encryption-config.yaml

# Apply the configuration for the kube-apiserver-to-kubelet
kubectl apply -f kube-apiserver-to-kubelet.yaml \
  --kubeconfig admin.kubeconfig

# Final context setup for fqdn-control.udev.local
kubectl config set-cluster fqdn-control.udev.local \
    --certificate-authority=${CA_CRT} \
    --embed-certs=true \
    --server=https://fqdn-control.udev.local:6443

kubectl config set-credentials admin \
    --client-certificate=${CERT_CRT} \
    --client-key=${CERT_KEY}

kubectl config set-context fqdn-control.udev.local \
    --cluster=fqdn-control.udev.local \
    --user=admin

kubectl config use-context fqdn-control.udev.local
