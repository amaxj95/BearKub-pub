#!/bin/bash

start_time=$(date +%s)

echo "Running playbook to deploy RKE2 Cluster w/ Argo, Harbor, Prometheus, Jenkins, & Minio"

ansible-playbook site.yml -i inventory/hosts.yml --ask-pass

end_time=$(date +%s)

duration=$(( end_time - start_time ))
minutes=$(( duration / 60 ))
seconds=$(( duration % 60 ))

echo "Playbook run duration: $minutes minutes and $seconds seconds"
