# Terraform (IaC)
## This repo only to understand, analyze, and apply terraform code to build infrastructures in cloud providers such as AWS
---
### Terraform Installation - Get code from Terraform docs
* Note: My Host Machine is Linux Mint OS.

```sh

wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

- Verifiying Intallation: ``` terraform --version ```

---

### AWS Setup
- Go to: ```portal.aws.amazon.com``` and signup/login an root account

![001](https://github.com/user-attachments/assets/5f45c3c6-2e5f-4950-9f72-d5b542ad0054)

- Add MFA
![image](https://github.com/user-attachments/assets/74f81dd2-703f-4f14-9c55-24c9f1c426f9)
![image](https://github.com/user-attachments/assets/4739a5bf-eecb-4ce6-9c31-2afb8e3c2b54)

                                                                                                       
- Create AWS Budget
![image](https://github.com/user-attachments/assets/f573f9c5-1654-40e6-81ff-b82217502815)
![image](https://github.com/user-attachments/assets/3d5222f5-25ee-4179-9a16-08c022cac0b2)

- Create IAM user - Admins Group with AdministratorAccess permission & Admin user
- Note:  AdministratorAccess permission -> administrative privilages in both GUI/CLI with limited visibility to finanitial info like (budgets, etc) [what I need]
![image](https://github.com/user-attachments/assets/aa18f635-a679-4bdc-bc9c-9935b6453e0f)
![image](https://github.com/user-attachments/assets/85e5e787-57b2-440e-bef8-d9ccdc4aa6e1)
![image](https://github.com/user-attachments/assets/995bcb99-a2b0-40c7-8850-9a00453aa00a)

- 

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
