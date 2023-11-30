# Terraform + Ansible Lab

An automated infrasture provisioning toolset to build a VPC and deploy applications

## Setup

### Install Terraform
[Full Instructions](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

```
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew update
brew upgrade hashicorp/tap/terraform
```

**Mac M1 Additional Steps**

While executing ```terraform init``` you may face

> Error: Incompatible provider version
> 
> Provider registry.terraform.io/hashicorp/template v2.2.0 does not have a package available for your current platform, darwin_arm64.
>  
> Provider releases are separate from Terraform CLI releases, so not all providers are available for all platforms. Other versions of this provider may have different platforms supported.



Fix this with the following steps:

```
brew install kreuzwerker/taps/m1-terraform-provider-helper
m1-terraform-provider-helper activate
m1-terraform-provider-helper install hashicorp/template -v v2.2.0
```

[source](https://discuss.hashicorp.com/t/template-v2-2-0-does-not-have-a-package-available-mac-m1/35099/7)


### Set Up AWS 
Create a new AWS access key 

1. Log in to AWS and head over to IAM

2. Select Users > Your User and open the security credentials tab

3. Select Create Access Key > Command Line Interface (CLI)

Configure you client machine to connect to AWS using the newly created access key. This can be done using the command line or the AWS extension if using VSCode 

**CLI**
[Full Instructions](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```
Then run ``` aws configure``` and enter the access key id, secret key & set default region to us-east-1

**VS Code Extension**

Open VS Code and select *Extensions* on the left side menu

Search "AWS" install "AWS Toolkit" (extension id: amazonwebservices.aws-toolkit-vscode)

1. Select View > Command Palette and enter AWS: Create Credentials Profile 

2. Enter your key id and secret access key
    
3. File created in ~/.aws/credentials
 

## Usage

A barebones environment consists of the networking module and a bastion host. The networking module creates a VPC, subnets, and gateways and the bastion host module creates a publicly accessable host that you can access with your ssh key. Once on this bastion host you can ssh into any other host deployed in the environment. 

**Configure**

In the terraform.tfvars file fill in your name, email, the customer this environment is for, and a name for the environment in the resource_tags map 

```
resource_tags = {

  Requestor   = "Justin Merlo"                   # Your Name
  Email       = "justin.merlo@servicelaunch.com" # Your Email
  Customer    = "SL"                             # Customer Lab is for
  Environment = "test-lab"                       #Purpose of the lab

}
```

Input the paths to a public and private ssh keys on your local machine in the public_access_key_file and private_access_key_file variables respectively. More details on this in the Key Management section. 

Define the cidr of the vpc to create as well as what availabilty zones to use. Then define lists of cidrs to use for public and private subnets. More details on this in the Networking Module section. 

**Define Infrastructure**

In the main.tf file add hosts or utilize an existing module. Be sure to make each module depend on the networking module so it gets created after the VPC and subnets exist. 

For the host module, pass a list of roles and var_files for ansible to use in its deployment. var_file are to be created in the app_configs folder and are uploaded to the bastion host on creation. More on this in the ansible section. 

```
module "app_host" {
  depends_on = [ module.networking ]
  source = "./modules/host"
  resource_tags = var.resource_tags
  ...
  group_name = "harbor-repo"
  roles = ["harbor"]
  var_files = ["harbor.yaml"]
  

}
```
Add each created piece to the depends_on list variable of the bastion host 

Each module, inculding the hosts outputs an ansible inventory and and ansible playbook. These outputs get aggregated and uploaded onto the bastion host by adding them to the inventories and playbooks variables of the bastion host module. 

```
module "bastion_hosts" {
  depends_on    = [module.networking, module.app_host]
  source        = "./modules/bastion"
  resource_tags = var.resource_tags
  ...
  ansible_inventories     = [module.app_host.inventory]
  ansible_playbooks       = [module.app_host.playbook]
}
```

**Deploy**

Initialize the repo with

```
terraform init
```

Verify your configuration is valid with

```
terraform validate
```

If there are no errors dry-run the deployment and review the changes with

```
terraform plan
```

Once ready to build the environment run

```
terraform apply
```

Terraform will ask to make sure you want to deploy the changes, accept the changes by typing ```yes``` 

**Destroy**

Once the lab environment is no longer need tear down the deployment with 

```
terraform destroy
```
[!] Terraform will ask to make sure you want to destroy the environment, accept the changes with ```yes``` 

## Terraform Docs

At a high level, the terraform portion of the repo is responsible for creating hosts and assigning roles to them for ansible to configure. Beyond this there are a few other repsonsibilities terraform takes on to make this process run smoothly

### Key Management

Two pairs of ssh keys are used. One pair that is located on you local machine and another that is generated while building. Your local public key is copied from your machine onto the bastion host to allow you to ssh onto it. The generated private key is also copied onto the bastion host while the generated public key is copied onto all other hosts in the build. This allows you to access any other host from the bastion host. 

You configure the locations of your local public and private keys in the terraform.tfvars file in the projects root folder. Your private key is never copied off of your machine, it is only used to ssh onto the bastion host to perform initial setup steps. 

### Modules 

The terraform portion of the repo is broken up into modules. Each module is responsible for creating the infrastucture it needs and outputing data to generate ansible files (playbook and inventory). Ansible configures hosts based on the roles assigned to it and variables can assigned to that configuration with the use of var_files. See the ansible section for more details.

```
output "playbook" {
  value = [{host = var.group_name
            roles = var.roles
            var_files = var.var_files  }]
         
}

output inventory {
  value = {"${var.group_name}" = aws_instance.host.*.private_ip}
}
```


**Networking Module**

[AWS VPC with 10.0.0.0/16 CIDR.](https://www.davidc.net/sites/default/subnets/subnets.html)

Multiple AWS VPC public subnets would be reachable from the internet; which means traffic from the internet can hit a machine in the public subnet.

Multiple AWS VPC private subnets which mean it is not reachable to the internet directly without NAT Gateway.

AWS VPC Internet Gateway and attach it to AWS VPC.

Public and private AWS VPC Route Tables.

AWS VPC NAT Gateway.

Associating AWS VPC Subnets with VPC route tables.

**Bastion Host Module**

**Host Module**

**Runtime Module**

## Ansible Docs

Terraform generates the playbook and inventory files and copies them onto the bastion host(s). The ansible folder as well as the app_configs folder also gets copied onto the bastion host(s). All of the ansible source files are loaded into /opt/ansible.

**Playbook**

The ansible playbook repeats the following pattern

```
- hosts: groupname
  become: true
  roles:
    - role1
    - role2
  vars_files:
    - /opt/ansible/var_files/config1.yaml
    - /opt/ansible/var_files/config2.yaml
```

The file is generated by the bastion host module from a nested list of maps with the following structure

```
{ host = groupname
  roles = [role1, role2]
  var_files = [config1.yaml, config2.yaml]  }
```

Each module is expected to output a list of these maps. The bastion host takes in a list of these lists, aggregates them together and generates the playbook file. 


**Inventory**

The ansible inventory repeats the following pattern

```
[groupname]
10.x.x.x
10.y.y.y
```

The file is generated by the bastion host module from a map with the following structure 

```
{groupname = [10.x.x.x, 10.y.y.y]}
```

Each module is expected to output this map. The bastion host module takes in a list of these maps which are merged together and generates the inventory file.

Additional variables can be loaded in via the inventory file with a pattern like

```
{groupname = ["10.x.x.x ansible_ssh_user=ec2-user", "10.y.y.y ansible_ssh_user=ec2-user"]}
```

which would generate 

```
[groupname]
10.x.x.x ansible_ssh_user=ec2-user
10.y.y.y ansible_ssh_user=ec2-user
```

and override the user ansible uses to ssh into the hosts

**App Configs**

Variables to configure the ansible application deployments are loaded in as yamls. Create these yamls in the app_config folder of this repo. This folder gets copied onto the bastion host(s) to /opt/ansible/var_files. The terraform outputs for the playbook need only specify which file to use, the full path the the file gets filled in when the playbook file is generated by the bastion host module.  

**Roles**

The ansible folder of this repo contains the source files to deploy applications. The directory is modularized in a reusable fashion as ansible roles. These roles are assigned to hosts via the playbook. 

## TODO
- Pull Ansible playbooks from separate git repo?