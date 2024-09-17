#!/bin/bash

kubectl create namespace argocd
sed -i 's,<YOUR.HARBOR.REGISTRY.example.com/quay.io/argoproj/argocd,,g' /root/rke2-artifacts/argo_admin/install.yaml # MODIFY HERE
kubectl apply --namespace argocd -f /root/rke2-artifacts/argo_admin/install.yaml
kubectl apply --namespace argocd -f /root/rke2-artifacts/argo_admin/argocd-cmd-params-cm.yaml
kubectl apply --namespace argocd -f /root/rke2-artifacts/argo_admin/argocd-ingress.yml
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout argocd-tls.key -out argocd-tls.crt -subj "/CN=fqdn-control.udev.local" \
-addext "subjectAltName=DNS:fqdn-control.udev.local"
kubectl create secret tls argocd-tls --key argocd-tls.key --cert argocd-tls.crt -n argocd
cp argocd-tls.crt /usr/local/share/ca-certificates/argocd-tls.crt
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
spec:
  rules:
  - host: argocd.fqdn-control.udev.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 443
  tls:
  - hosts:
    - fqdn-control.udev.local
    secretName: argocd-tls
EOF
kubectl --namespace argocd rollout restart deployment argocd-server
kubectl apply --namespace argocd -f /root/rke2-artifacts/argo_admin/argocd-cm.yaml
kubectl patch svc argocd-server -n argocd -p \
'{"spec": {"type": "NodePort", "ports": [{"name": "http", "nodePort": 30080, "port": 80, "protocol": "TCP", "targetPort": 8080}, {"name": "https", "nodePort": 30443, "port": 443, "protocol": "TCP", "targetPort": 8080}]}}'
openssl s_client -showcerts -connect https://fqdn-control.udev.local
openssl s_client -showcerts -connect fqdn-control.udev.local:443
echo | openssl s_client -showcerts -servername fqdn-control.udev.local -connect fqdn-control.udev.local:443 2>/dev/null | openssl x509 -outform PEM > fqdn-control.udev.local.crt
sudo cp fqdn-control.udev.local.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
kubectl create configmap argocd-ca-cert --from-file=fqdn-control.udev.local.crt