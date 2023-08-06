# Vault + Consul Cluster

Projeto contendo criação de um cluster Vault utilizando como storage backend o Consul, produto também da Hashicorp. 

A documentação sobre esta instalação pode ser vista aqui: https://developer.hashicorp.com/Vault/tutorials/day-one-Consul/ha-with-Consul

Assim como no excelente curso da LinuxTips sobre Vault: https://www.linuxtips.io/course/descomplicando-o-Vault

## Dependencias 

Packer >= 1.9.2
Terraform >= 1.5.4
Bucket S3 e chave SSH Criadas na AWS

## Conteudo 

Com o packer provisionamos duas AMI's, uma contendo o Consul instalado e outra contendo o Vault e o Consul instalados. 

Através do terraform fazemos a criação das instancias, o numero de maquinas é definido pela variavel 'cluster_machine_number' o tipo da instancia definido pela variavel 'instance_type' ambas presentes no arquivo variables.tf.

### Packer

Através do packer, as imagens AMI são criadas, desta vez, temos duas imagens muito simples, e não temos testes escritos ainda para ambas as imagens. 

A execução de um user data ou até mesmo no momento do provisionamento eliminaria a necessidade de utilização do Packer aqui. Porém usando o packer temos um melhor controle do que estamos instalado nas imagens, e podemos fazer modificações apenas nela, sem alterar sempre o conteudo e infra do terraform. 

### Terraform 

Além de criar as instancias do Consul e do Vault, também é a etapa que configuramos os respectivos serviços nas instancias, e também as configurações especificas de cada serviço. 

Através dos arquivos localizados no folder 'templates' configuramos o seguinte: 

- Consul-client.tpl : Arquivo que configurar o Consul como client, é armazenado nas instancias do Vault, que utilizam o Consul como client para conexão ao cluster. 

- Consul.service : Instancia um serviço do Consul, para facilitar gerencimaneo utilizando o systemctl. 

- Consul.tpl : Arquivo que configura o Consul como server, especifico para as instancias do Consul que serão o backend do Vault.

- Vault.service: Cria e facilita o gerenciamento do serviço através do systemctl para o Vault.

- Vault.tpl: Arquivo que irá virar um .hcl contendo as configurações necessárias para backend, cluster e afins do Vault. 

Este provisionamento é feito utilizando remote-exec e null_resources do terraform. 

## Como executar 

1 - Crie as imagens utilizando packer, acesse o respectivo diretório, primeiro do Consul e depois do Vault, por exemplo, e execute o comando. 

```
# Criando imagem do Consul
cd /packer/Consul 
packer validate Consul.pkr.hcl 
packer build Consul.pkr.hcl 

# Criando imagem do Vault 
cd /packer/Vault
packer validate Vault.pkr.hcl
packer build Vault.pkr.hcl 
```

Com as AMI's criadas, podemos partir para criação do cluster

2 - Para criar o cluster, execute o terraform na raiz do projeto


Para alterar tipo de instancia, portas liberadas no security group ou numero de instancias, acesse e modifique o arquivo 'variables.tf'


```
# Planejando a execução
terraform plan --out plano

# Executando

terraform apply "plano"

```


## Backlog 

- Configurar SSL/TLS para Vault
- Configurar um LB para o Vault
- Criar as instancias em regiões diferentes da AWS
