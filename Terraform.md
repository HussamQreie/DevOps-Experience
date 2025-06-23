# Terraform (IaC)
## This repo only to understand, analyze, and apply terraform code to build infrastructures in cloud providers such as AWS
---
### Requirements
- Terraform CLI + add env variable to that path
- Terraform UI 
- AWS Account 
- Terraform Account
- AWS User with full admin access (Terraform Gateway to AWS) + Secret Key and Session ID
- Access key in Terraform variables. done :)
---
### Terraform Structure
#### main folder
- main.tf
- .pem file 
- modules folders (network,servers)
---
### Terraform commands
- `terraform login` - connect cli with ui
- `terraform init` - in main.tf folder - initalize folder for build
- `terraform plan` - build plan
- `terraform apply` - apply build
---
### Analyze main.tf
#### How to write it?
##### Specify below
- output variables Storage space (org,workspace)
- cloud provider (aws, azure, gcp, etc)
- cloud provider region
- input variables 
- network module
- servers module
- dns records
- fetch cloud provider data
- output variables

tools? check .yml files
```tf

terraform {
  backend "remote" {
    organization = "HUISSEC_ORG" // modify this 

    workspaces {
      name = "RT-Infrastructure" // modify this 
    }
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.35.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
}

variable "phishing_zone_id" {
    type = string
    default = ""
}

variable "c2_zone_id" {
    type = string
    default = ""
}

#Creating our main VPC and subnets
module "redteam_network" {
    source = "./networks"
    env = "dev"
    cidr_prefix = "172.16"
}

#Creating our Red Team Caldera C2 Server
module "caldera_c2" {
    source = "./caldera-c2"
    env = "dev"
    subnet_cidr_prefix = module.redteam_network.redteam_subnet_cidr_prefix
    vpc_id = module.redteam_network.redteam_vpc
    subnet_id = module.redteam_network.redteam_subnet
}

#Creating our Red Team C2 Redirector Server
module "c2_redirector" {
    source = "./redirector"
    env = "dev"
    subnet_cidr_prefix = module.redteam_network.redteam_subnet_cidr_prefix
    vpc_id = module.redteam_network.redteam_vpc
    subnet_id = module.redteam_network.redteam_subnet
    caldera_public_ip = module.caldera_c2.caldera_public_ip
}

#Create Our Phishing Servers (GoPhish & Evilginx)
module "phishing" {
    source = "./phishing"
    env = "dev"
    subnet_cidr_prefix = module.redteam_network.redteam_subnet_cidr_prefix
    vpc_id = module.redteam_network.redteam_vpc
    subnet_id = module.redteam_network.redteam_subnet
}

/*
#Setup Our Phishing Domain
resource "aws_route53_record" "phishing_evilginx" {
  allow_overwrite = true
  #name            = var.phishing_domain
  name            = "www"
  ttl             = 172800
  type            = "A"
  zone_id         = var.phishing_zone_id

  records = [
    module.phishing.evilginx_public_ip,
  ]
}

#Setup Our GoPhish Domain (https://go.xxxx.xxx)
resource "aws_route53_record" "phishing_gophish" {
  allow_overwrite = true
  #name            = var.phishing_domain
  name            = "go"
  ttl             = 172800
  type            = "A"
  zone_id         = var.phishing_zone_id

  records = [
    module.phishing.gophish_public_ip,
  ]
}

#Setup Our C2 Domain (Pointrs to redirector)
resource "aws_route53_record" "C2" {
  allow_overwrite = true
  #name            = var.c2_domain
  name            = "www"
  ttl             = 172800
  type            = "A"
  zone_id         = var.c2_zone_id

  records = [
    module.c2_redirector.redirector_public_ip,
  ]
}
*/
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

output "vpc_id" {
    value = module.redteam_network.redteam_vpc
} 

output "subnet_id" {
    value = module.redteam_network.redteam_subnet
} 

output "subnet_cidr_prefix" {
    value = module.redteam_network.redteam_subnet_cidr_prefix
} 

output "caldera_public_ip" {
    value = module.caldera_c2.caldera_public_ip
} 

output "redirector_public_ip" {
    value = module.c2_redirector.redirector_public_ip
} 

output "gophish_public_ip" {
  value       = module.phishing.gophish_public_ip
  description = "The public IP of the GoPhish EC2 machine"
}

output "evilginx_public_ip" {
  value       = module.phishing.evilginx_public_ip
  description = "The public IP of the Evilgnix2 EC2 machine"
}

```
