#! /bin/bash

#Verifica se a instancia na AWS ja iniciou para então começar o provisionamento
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do 
    echo 'Waiting for cloud-init...'; 
    sleep 1; 
done


#Install consul, necessary due to consul agent

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

#Install Vault

sudo mkdir /etc/vault
sudo mkdir /var/lib/vault
sudo mkdir /var/log/vault
sudo useradd -r vault
sudo chown -R vault:vault /etc/vault
sudo chown -R vault:vault /var/lib/vault
sudo chown -R vault:vault /var/log/vault
sudo wget https://releases.hashicorp.com/vault/1.14.1/vault_1.14.1_linux_amd64.zip
sudo unzip vault_1.14.1_linux_amd64
sudo mv vault /usr/local/bin/vault
sudo vault version
sudo vault -autocomplete-install