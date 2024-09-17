# [DevOps CI Cluster Tools](https://fqdn-control.udev.local) 
<br>
Requirements, 3 VM's, a DNS server and already setup endpoints for the pods. It's also possible to just use localhost:80 but for organization purposes, its recommended to set up your DNS similar to the following:<br> 

https://prometheus.fqdn-control.udev.local <br>
https://argocd.fqdn-control.udev.local <br>
https://harbor.fqdn-control.udev.local <br> 
https://minio.fqdn-control.udev.local <br>

## Summary
Airgapped private cluster, modify the inventory/hosts and add your machine IP addresses or FQDN name. This playbook has been modified from original purposes and needs modification to fit your collaborative team efforts. where you see fqdn-control.udev.local replace with your machine udev domain (example.udev.local || example.local.com)

# [Herramientas para el Clúster de CI de DevOps](https://fqdn-control.udev.local) 
<br>
Requisitos: 3 máquinas virtuales, un servidor DNS y puntos finales ya configurados para los pods. También es posible usar localhost:80, pero por motivos de organización, se recomienda configurar tu DNS de manera similar a lo siguiente:<br>

https://prometheus.fqdn-control.udev.local <br>
https://argocd.fqdn-control.udev.local <br>
https://harbor.fqdn-control.udev.local <br>
https://minio.fqdn-control.udev.local <br>

## Resumen
Clúster privado aislado, modifica el archivo inventory/hosts y agrega las direcciones IP o el nombre FQDN de tus máquinas. Este playbook ha sido modificado de sus propósitos originales y necesita ajustes para adaptarse a los esfuerzos colaborativos de tu equipo. Donde veas fqdn-control.udev.local, reemplázalo por el dominio de tu máquina udev (ejemplo.udev.local || ejemplo.local.com).

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

## Instalación Manual - Servidor 

>> mkdir /root/rke2-artifacts && cd /root/rke2-artifacts/ <br>
>> curl -OLs https://github.com/rancher/rke2/releases/download/v1.30.1%2Brke2r1/rke2-images.linux-amd64.tar.zst <br>
>> curl -OLs https://github.com/rancher/rke2/releases/download/v1.30.1%2Brke2r1/rke2.linux-amd64.tar.gz <br>
>> curl -OLs https://github.com/rancher/rke2/releases/download/v1.30.1%2Brke2r1/sha256sum-amd64.txt <br>
>> curl -sfL https://get.rke2.io --output install.sh <br>
>> scp rke2-artifacts/* <USERNAME>@<CONTROLPLANE>:/tmp <br>
>> scp install.sh <USERNAME>@<CONTROLPLANE>:/tmp <br>

Una vez que los archivos se hayan descargado y copiado a la VM, haz ssh en la máquina del plano de control. Una vez en ssh, copia los tarballs y el checksum desde /tmp a rke2-artifacts. Luego en tu terminal desde el directorio root: <br>

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
>> sudo rm /usr/local/bin/kubectl * # Solo ejecutar si ln: failed to create symbolic link '/usr/local/bin/kubectl': File exists error shows<br>
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

## Instalación Manual - Agente

Copia los mismos archivos tarball desde las máquinas host a tus nodos worker. <br>

>> export CONTROLPLANE_IP='CONTROLPLANE' <br>
>> export TOKEN=/var/lib/rancher/rke2/server/node-token <br>
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
>> INSTALL_RKE2_ARTIFACT_PATH=/root/rke2-artifacts sh install.sh <br>
>> mkdir -p /etc/rancher/rke2/ <br>
>> echo "server: https://$CONTROLPLANE_IP:9345" > /etc/rancher/rke2/config.yaml <br>
>> echo "token: $TOKEN" >> /etc/rancher/rke2/config.yaml <br>
>> systemctl enable rke2-agent.service <br>
>> systemctl start rke2-agent.service <br>

# Automated with Ansible

Edit the ansible.cfg and unventory/hosts.yml accordingly. then run the following, in a terminal: <br> 
>> ansible-playbook site.yml -i inventory/hosts.yml --ask-pass <br>

When successful, you should be able to type: <br>
>> kubectl get nodes <br>

With all nodes showing ready.

# Automatizado con Ansible

Edita el archivo ansible.cfg y inventory/hosts.yml en consecuencia. Luego ejecuta lo siguiente, en una terminal: <br> 
>> ansible-playbook site.yml -i inventory/hosts.yml --ask-pass <br>

Si es exitoso, deberías poder escribir: <br>
>> kubectl get nodes <br>

Con todos los nodos mostrando "ready".

# Performance Engineering

In your terminal:<br>
>> chmod +x launch.sh <br>
>> ./launch.sh<br>

The playbook takes a good amount of time to set up and run everything when there are no errors. Changes made should not only solve problems, but reduce overall run time of the playbook. the launch script is essentially the automated with ansible command, wrapped in a timer. 

# Ingeniería de Rendimiento

En tu terminal:<br>
>> chmod +x launch.sh <br>
>> ./launch.sh<br>

El playbook tarda un buen tiempo en configurarse y ejecutar todo cuando no hay errores. Los cambios realizados no solo deben resolver problemas, sino también reducir el tiempo total de ejecución del playbook. El script launch es esencialmente el comando automatizado con ansible, envuelto en un temporizador.

# Cleanup

To clean up, in your terminal, type: <br>
>> chmod +x teardown.sh <br>
>> ./teardown.sh<br>

All cluster data and created certs will be deleted. It's not a bad idea to run teardown first prior to running the cluster installation script to ensure that everything installs fresh.  

# Limpieza

Para limpiar, en tu terminal, escribe: <br>
>> chmod +x teardown.sh <br>
>> ./teardown.sh<br>

Todos los datos del clúster y los certificados creados serán eliminados. No es una mala idea ejecutar teardown primero antes de ejecutar el script de instalación del clúster para asegurarse de que todo se instale desde cero.