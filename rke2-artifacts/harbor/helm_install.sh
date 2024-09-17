#!/bin/bash

# You'll need to modify the default helm values.yaml file

# Create the namespace if it does not exist
kubectl create namespace harbor-system

cat <<EOF > label.yml
apiVersion: v1
kind: Namespace
metadata:
  name: harbor-system
  labels:
    app: kubed
EOF

kubectl apply -f label.yml

# Add the Harbor Helm repository
helm add harbor

# Update Helm repositories
helm repo update

# Generate TLS certificates for Harbor
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout harbor.fqdn-control.udev.local.key -out harbor.fqdn-control.udev.local.crt \
  -subj "/CN=harbor.fqdn-control.udev.local/O=harbor.fqdn-control.udev.local"

# Create a Kubernetes secret to store the TLS certificates
kubectl create secret tls harbor-tls --cert=harbor.fqdn-control.udev.local.crt --key=harbor.fqdn-control.udev.local.key --namespace=harbor-system

# MODIFY THE FOLLOWING LINE
helm install -f values.yaml 

# Install Harbor using Helm, passing the necessary values for Traefik Ingress and TLS
helm install harbor harbor --namespace harbor-system \
  --set expose.tls.enabled=true \
  --set expose.tls.secretName=harbor-tls \
  --set expose.ingress.hosts.core=harbor.fqdn-control.udev.local \
  --set expose.ingress.ingressClassName=traefik \
  --set externalURL=https://harbor.fqdn-control.udev.local \
  --set persistence.persistentVolumeClaim.registry.existingClaim=data-harbor-redis-0 \
  --set persistence.persistentVolumeClaim.chartmuseum.existingClaim=data-harbor-redis-0 \
  --set persistence.persistentVolumeClaim.jobservice.existingClaim=data-harbor-redis-0 \
  --set persistence.persistentVolumeClaim.trivy.existingClaim=data-harbor-redis-0

# Output the Harbor access information
echo "Harbor has been successfully deployed!"
echo "You can access it at: https://harbor.fqdn-control.udev.local"