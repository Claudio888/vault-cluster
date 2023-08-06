#! /bin/bash

#Verifica se a instancia na AWS ja iniciou para então começar o provisionamento
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do 
    echo 'Waiting for cloud-init...'; 
    sleep 1; 
done


sudo mkdir /etc/consul 
sudo mkdir /var/lib/consul
sudo useradd -r consul 
sudo chown -R consul:consul /etc/consul 
sudo chown -R consul:consul /var/lib/consul
sudo wget https://releases.hashicorp.com/consul/1.16.0/consul_1.16.0_linux_amd64.zip
sudo apt-get install unzip
sudo unzip consul_1.16.0_linux_amd64
sudo mv consul /usr/local/bin/consul
sudo consul version