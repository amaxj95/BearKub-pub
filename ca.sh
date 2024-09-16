#!/bin/bash

# Define the directories for storing the certificates
CERT_DIR="/etc/kubernetes/pki"
ROOT_DIR="/root/certs"

# Create the directories if they don't exist
sudo mkdir -p $CERT_DIR
sudo mkdir -p $ROOT_DIR

# Function to generate certificates and keys
generate_certificates() {
  local name=$1

  # Generate a private key
  openssl genrsa -out "${name}.key" 4096

  # Generate a certificate signing request (CSR)
  openssl req -new -key "${name}.key" -sha256 -config "ca.conf" -out "${name}.csr"

  # Generate a self-signed certificate
  openssl x509 -req -days 3653 -in "${name}.csr" -sha256 -CA "ca.crt" -CAkey "ca.key" -CAcreateserial -out "${name}.crt"

  # Create a .pem file by combining the certificate and key
  cat "${name}.crt" "${name}.key" > "${name}.pem"

  # Move the generated files to the CERT_DIR and ROOT_DIR
  sudo mv "${name}.key" "${CERT_DIR}/${name}.key"
  sudo mv "${name}.crt" "${CERT_DIR}/${name}.crt"
  sudo mv "${name}.pem" "${CERT_DIR}/${name}.pem"

  sudo cp "${CERT_DIR}/${name}.key" "${ROOT_DIR}/${name}.key"
  sudo cp "${CERT_DIR}/${name}.crt" "${ROOT_DIR}/${name}.crt"
  sudo cp "${CERT_DIR}/${name}.pem" "${ROOT_DIR}/${name}.pem"

  sudo rm "${name}.csr"
}

# Generate CA key and certificate
{
  openssl genrsa -out ca.key 4096
  openssl req -x509 -new -sha512 -key ca.key -days 3653 -config ca.conf -out ca.crt

  # Move the CA key and certificate to the CERT_DIR and ROOT_DIR
  sudo mv ca.key "${CERT_DIR}/ca.key"
  sudo mv ca.crt "${CERT_DIR}/ca.crt"

  sudo cp "${CERT_DIR}/ca.key" "${ROOT_DIR}/ca.key"
  sudo cp "${CERT_DIR}/ca.crt" "${ROOT_DIR}/ca.crt"
}

# List of certificates to generate
certs=(
  "admin" "client" "worker-01" "worker-02"
  "kube-proxy" "kube-scheduler" "traefik"
  "kube-controller-manager"
  "kube-api-server" "argocd"
  "service-accounts" "tls"
)

# Generate certificates for each entry in the list
for cert in "${certs[@]}"; do
  generate_certificates "$cert"
done

echo "All certificates have been generated and moved to ${CERT_DIR} and ${ROOT_DIR}."
