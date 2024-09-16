#!/bin/bash

start_time=$(date +%s)

echo "Deleting Cluster data and certs. . . "

ansible-playbook teardown.yml -i inventory/hosts.yml --ask-pass

end_time=$(date +%s)

duration=$(( end_time - start_time ))
minutes=$(( duration / 60 ))
seconds=$(( duration % 60 ))

echo "Playbook run duration: $minutes minutes and $seconds seconds"
