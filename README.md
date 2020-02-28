# Jugando con Terraform.

Este repo construye el conjunto de recursos necesarios para crear un ec2 con una ip pública (Elastic Ip) usando el paradigma IaC (Infrastructure as Code) y terraform.
Los recursos que se crean son: 

 1. Vpc.
 2. Subnet.
 3. Internet Gateway.
 4. Route Table.
 5. Route Table Association.
 6. Security Group
 7. Ec2.
 8. Elastic Ip.
 9. key_pair

![alt text](https://github.com/arthur-rock/example-terraform/blob/master/images/vpc_subnet_custom_route_table_ec2.png)

## Requisitos.

 1. Una cuenta de aws y nuestro aws-cli versión 2 configurado.  https://docs.aws.amazon.com/es_es/cli/latest/userguide/cli-chap-install.html
 2. El cliente de Terraform.
  https://learn.hashicorp.com/terraform/azure/install_az
  
 3. Permisos para crear los recursos antes descritos.

## Ejecución.

>  $ git clone git@github.com:arthur-rock/example-terraform.git

>  $ terraform init 

>  $ terraform apply
 
## Limpieza de ambiente


>  $ terraform destroy