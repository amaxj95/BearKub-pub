# [DevOps CI Cluster Tools](https://fqdn-control.udev.local) 
<br>
https://prometheus.fqdn-control.udev.local <br>
https://argocd.fqdn-control.udev.local <br>
https://harbor.fqdn-control.udev.local <br> 
https://minio.fqdn-control.udev.local <br>

## Summary
Airgapped private cluster, modify the inventory/sewol/hosts and add your machine IP addresses or FQDN name. This playbook has been modified from original purposes and needs modification to fit your collaborative team efforts. where you see fqdn-control.udev.local replace with your machine udev domain (example.udev.local || example.local.com)
## Manual Installation - Server 

>> mkdir /root/rke2-artifacts && cd /root/rke2-artifacts/ <br>
>> curl -OLs https://github.com/rancher/rke2/releases/download/v1.30.1%2Brke2r1/rke2-images.linux-amd64.tar.zst <br>
>> curl -OLs https://github.com/rancher/rke2/releases/download/v1.30.1%2Brke2r1/rke2.linux-amd64.tar.gz <br>
>> curl -OLs https://github.com/rancher/rke2/releases/download/v1.30.1%2Brke2r1/sha256sum-amd64.txt <br>
>> curl -sfL https://get.rke2.io --output install.sh <br>
>> scp rke2-artifacts/* <USERNAME>@<CONTROLPLANE>:/tmp <br>
>> scp install.sh <USERNAME>@<CONTROLPLANE>:/tmp <br>

After files are downloaded and copied to the VM, ssh to the control plane machine. Once ssh'd in, copy the tarballs and checksum from /tmp to rke2-artifacts. Then in your terminal from root directory: <br>

>> mkdir rke2-artifacts <br>
>> cp /tmp/rke2.linux-amd64.tar.gz rke2-artifacts <br>
>> cp /tmp/rke2-images.linux-amd64.tar.zst rke2-artifacts <br>
>> cp /tmp/sha256sum-amd64.txt rke2-artifacts <br>
>> cp /tmp/install.sh rke2-artifacts <br>
>> systemctl stop fapolicyd <br>
>> setenforce 0 <br>
>> INSTALL_RKE2_ARTIFACT_PATH=/root/rke2-artifacts sh install.sh <br>
>> systemctl enable rke2-server <br>
>> systemctl start rke2-server <br>
>> sudo rm /usr/local/bin/kubectl * # Only run if ln: failed to create symbolic link '/usr/local/bin/kubectl': File exists error shows<br>
>> ln -s $(find /var/lib/rancher/rke2/data/ -name kubectl) /usr/local/bin/kubectl <br>
>> echo "export KUBECONFIG=/etc/rancher/rke2/rke2.yaml PATH=$PATH:/usr/local/bin/:/var/lib/rancher/rke2/bin/" >> ~/.bashrc <br>
>> source ~/.bashrc <br>
>> kubectl get node <br>
>> cat /var/lib/rancher/rke2/server/node-token <br>

## Manual Installation - Agent

Copy the same tarball files from the host machines to your worker nodes. <br>

>> export CONTROLPLANE_IP='CONTROLPLANE' <br>
>> export TOKEN=/var/lib/rancher/rke2/server/node-token 
>> scp rke2-artifacts/* <USERNAME>@<WORKER_1>:/tmp <br>
>> scp install.sh <USERNAME>@<WORKER_1>:/tmp <br>
>> scp rke2-artifacts/* <USERNAME>@<WORKER_2>:/tmp <br>
>> scp install.sh <USERNAME>@<WORKER_2>:/tmp <br>
>> mkdir rke2-artifacts <br>
>> cp /tmp/rke2.linux-amd64.tar.gz rke2-artifacts <br>
>> cp /tmp/rke2-images.linux-amd64.tar.zst rke2-artifacts <br>
>> cp /tmp/sha256sum-amd64.txt rke2-artifacts <br>
>> cp /tmp/install.sh rke2-artifacts <br>
>> systemctl stop fapolicyd <br>
>> setenforce 0 <br>
>> INSTALL_RKE2_ARTIFACT_PATH=/root/rke2-artifacts sh install.sh
>> mkdir -p /etc/rancher/rke2/ <br>
>> echo "server: https://$CONTROLPLANE_IP:9345" > /etc/rancher/rke2/config.yaml <br>
>> echo "token: $TOKEN" >> /etc/rancher/rke2/config.yaml <br>
>> systemctl enable rke2-agent.service <br>
>> systemctl start rke2-agent.service <br>

# Automated with Ansible

Edit the ansible.cfg and unventory/hosts.yml accordingly. then run the following, in a terminal: <br> 
>> ansible-playbook site.yml -i inventory/sewol/hosts.yml --ask-pass <br>

When successful, you should be able to type: <br>
>> kubectl get nodes <br>

With all nodes showing ready.


# Performance Engineering

In your terminal:<br>
>> chmod +x launch.sh <br>
>> ./launch.sh<br>

The playbook takes a good amount of time to set up and run everything when there are no errors. Changes made should not only solve problems, but reduce overall run time of the playbook. the launch script is essentially the automated with ansible command, wrapped in a timer. 

# Cleanup

To clean up, in your terminal, type: <br>
>> chmod +x teardown.sh <br>
>> ./teardown.sh<br>

All cluster data and created certs will be deleted. It's not a bad idea to run teardown first prior to running the cluster installation script to ensure that everything installs fresh.  