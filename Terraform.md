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

- AWS CLI Installation and API Access Keys Configuration
- Note: Programmatically access (CLI) requires to create access keys (accessKeys(like->un)&SecretKey(like->passwd)
![image](https://github.com/user-attachments/assets/e58bea51-c4fe-4571-8ca3-e7a637736220)
![image](https://github.com/user-attachments/assets/acc9ee58-c2db-4894-8bec-d126daaa6875)
- Write `aws configure` command then add below:
- Access key
- Secret Key
- Region -> I used `eu-central-1` where is the closest region to me.

Now! you can access aws account via CLI, write `aws help` will list you the services you can manage.
for example you can use command like `aws iam list-users`

- hint: always to see what commands available use help: `aws help` `aws iam help` and so on. 

### Terraform Setting Up and Adding VSC Terraform plug-in
Note: 
- terraform/ directory is the workspace
- search `terraform aws provider` to know how to setup terraform with the provider, `aws` can be replaced with any service provider you want.
- Don't take resources code [we are in setup phase].

Now, in workspace create a file called `provider.tf` and paste the code. [In this file you can use single/multiple providers but In this case we only deal with AWS] 
 

  ![image](https://github.com/user-attachments/assets/5f667826-7bfd-4b24-8b98-fc14dee4ff7c)
  ![image](https://github.com/user-attachments/assets/c6f98872-df2f-4da0-a3ec-fcded0f268ef)

Open a terminal and write `aws configure` it will recognize you did that before just accept enter enter enter.
* Note: everything in code will overwrite on terminal options like region so be aware of that.
![image](https://github.com/user-attachments/assets/316d94ee-a171-4b7f-926e-98276355f4d1)
- Terraform init
* Note:
- This installs all binaries needed to deal with aws within specific/scope version of terraform like `>5`
 
![image](https://github.com/user-attachments/assets/c1b38e4c-e32e-4ed4-8df7-219b851af695)
![image](https://github.com/user-attachments/assets/5eb9c131-5b17-4c0c-aa1b-574002bafd23)

### Build A Virtual Server Using Terraform
Note: Before resource creation ensure you are using AWS IAM account not root account to notice changes in aws managememt console.
- Search `terraform <resourceName> resource` like `terraform ec2 resource` and find out the code.
- Create a file called `server0.tf` in terraform workspace and add the code in it
![image](https://github.com/user-attachments/assets/7fc33e01-f7c0-4875-bdb8-b5ab34a4c5cc)
![image](https://github.com/user-attachments/assets/74f93558-ec97-4274-9158-9af648258efa)

Now! write `terraform plan` to build a plan about changes you want to make in aws provider work environment.
then write `terraform apply` to  execute your code as actions in AWS - IaC
![image](https://github.com/user-attachments/assets/b6ae441a-8e38-42a3-96ac-e4e9a200a690)
![image](https://github.com/user-attachments/assets/958cb46b-6843-42d6-994b-123944a58948)
![image](https://github.com/user-attachments/assets/d7bfad73-1e1b-48c9-9778-4818d8bfdf98)

Notice that if you do `terraform apply` again, terraform checks and compares your code with `terraform.tfstate` file - explained below - which contains all info related to resources created in the cloud to see if there are changes to apply.
![image](https://github.com/user-attachments/assets/085381b9-858f-45b7-b46a-c399f46c0528)

To Remove a resource from terraform use `terraform destroy` command
![image](https://github.com/user-attachments/assets/9045039d-ad64-4099-b75a-f41b31175b20)


### Create AWS VPC using Terraform
  * Note: there is a default vpc which is the main network in AWS and contains all instances if not specified/customized.
![image](https://github.com/user-attachments/assets/dd44011b-98f9-452d-86ce-52bca8001b55)

  * Default VPC CIDR
    
![image](https://github.com/user-attachments/assets/1bf16ab1-63f0-4be6-a190-3ac32f54110b)

  * Defualt VPC has 3 Subnets
    
![image](https://github.com/user-attachments/assets/8b39c9a4-f931-4b9f-bfc8-1dbfa1a9b2ef)
![image](https://github.com/user-attachments/assets/150bf557-02e3-4fb6-879a-8f4938441a8b)
![image](https://github.com/user-attachments/assets/9596b693-c606-4cf1-86dc-13e5bdd4c86f)


Let's create own VPC:
- Search as we did above
- create a file called `vpc.tf` in terraform/ folder.
- customize code to your needs
- comment server resource for now! -> select all then ctrl+ /  to comment all content.
- `terraform plan` and `terraform apply` -> note that all .tf in workspace are used via this command so we commented `server0.tf`, but `provider.tf` always should be exist when create any resource (ec2, vpc, etc...)


![image](https://github.com/user-attachments/assets/53d4d59c-5e47-4380-bd8d-8a6c36a43d5f)
![image](https://github.com/user-attachments/assets/c016fcc7-6920-464f-8265-9e0cf6c39890)
![image](https://github.com/user-attachments/assets/60cc025f-afea-45a9-b7ad-158d5d960343)

Let's create subnets of own VPC:
- Search as we did above
- Add code to `vpc.tf` file.
- customize code to your needs
- write `terraform graph` to view dependencies -> connect resources vpc with subnet in this case
- `terraform plan` and `terraform apply`
Note: In this case below you can add up to 3 subnets in the main network (3 of /26 in main /24) - [Free Account capacity is 3 subnets]

![image](https://github.com/user-attachments/assets/f2296f43-56a3-4630-8a6c-662669a36671)
![image](https://github.com/user-attachments/assets/da2660fc-b451-487a-b0ea-e2da2eb7b418)
![image](https://github.com/user-attachments/assets/3e909596-342d-4702-84a3-99fb718689fe)
![image](https://github.com/user-attachments/assets/fe48352c-63a1-4677-b3ee-d78ab611da26)
![image](https://github.com/user-attachments/assets/4c9156f4-38e2-494e-9e34-ae70dae50b12)

              
### Handle them all
Create virtual server, vpc, subnet, and network interface(which assigns private ip to virtual server)
files:
- `vpc0.tf` -> main network
- `subnet0.tf` -> subnets
- `server0.tf` -> virtual server + network interface
- `provider.tf` -> tf version for aws

![image](https://github.com/user-attachments/assets/0ba9c25e-8527-4eb5-98a9-caf5aec62566)
![image](https://github.com/user-attachments/assets/2d7d6846-7883-48ac-9cda-98a0e531a261)
![image](https://github.com/user-attachments/assets/37571a35-c178-4693-b1ce-60ff1cf5ba65)
![image](https://github.com/user-attachments/assets/7ff5eb9e-e817-4159-8382-9ada2805271f)

#### `terraform plan` and `terraform apply`
![image](https://github.com/user-attachments/assets/5ac12c0b-524f-4f42-b5c4-6aadf5f88161)
![image](https://github.com/user-attachments/assets/756bfccd-1f3b-45b5-9779-43aa7eecb62a)

`terraform destroy` 

### `terraform.tfstate` file
 every resource created in the cloud its info stored locally in `terraform.tfstate` file (unfriendly-file when create a resource)
 what can you do?
 - `terraform state --help`
 - `terraform state list` -> show your infrastructure resources
 - `terraform state show <resource>` -> show details about a resource
![image](https://github.com/user-attachments/assets/7ccbe974-507e-4e4c-8a52-dd325c476735)

important note: In work environment, a team works in same infrastrature may leads to conflicts so the solution is this file! how? it is locked/reserved to one person until he finishs his changes
then another one can update the infrastructure by reserve. [`terraform.tfstate` locked(reserved)/unlocked in cloud using s3 service]
so I will:
- Create S3 bucket
- Add terraform backend code in `provider.tf` file to store `terraform.tfstate` in the s3 bucket and allow lock mechanism
![image](https://github.com/user-attachments/assets/7a997d30-4220-4df2-9ead-bfe44de98670)
![image](https://github.com/user-attachments/assets/d746ad32-5c63-4410-b5a6-82e628612a76)
![image](https://github.com/user-attachments/assets/5233dd39-8daf-4f1f-b380-1dcd67598ffb)
![image](https://github.com/user-attachments/assets/fcdfaa4d-b7d4-4e4d-8a4e-38e1f4ef90fe)

Note: if you update `provider.tf` execute `terraform init` command to update backend infrastructure.
![image](https://github.com/user-attachments/assets/e83ef4db-7c34-470b-88d6-cfeb3b524a32)
![image](https://github.com/user-attachments/assets/0da2f271-f639-4ff6-b926-6425e3ffb0c8)
![image](https://github.com/user-attachments/assets/3b501335-6b42-4af4-b520-0ffab700f240)

Now! no one can make changes on this file if it is locked/reserved by another one.

`terraform destroy --auto-approve` -> destroy and confirm.

#### Variables 
Imagine you deal with 1000 instances! should you name or assign values one by one? no. so use variables as templates in your code would save your time.
![image](https://github.com/user-attachments/assets/597a2def-4c3b-412e-9758-074aad03bd7d)
![image](https://github.com/user-attachments/assets/a8b9a763-facb-48af-9aa7-2972ae21e2eb)

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
