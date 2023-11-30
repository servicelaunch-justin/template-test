resource_tags = {

  Requestor   = "Justin Merlo"                   # Your Name
  Email       = "justin.merlo@servicelaunch.com" # Your Email
  Customer    = "HPE Federal"                             # Customer Lab is for
  Environment = "Chargeback lab"                       #Purpose of the lab

}

public_access_key_file  = "~/.ssh/id_ed25519.pub"
private_access_key_file = "~/.ssh/id_ed25519"

//AWS 
region = "us-east-2"


/* module networking */
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-2a"]
public_subnets_cidr  = ["10.0.1.0/24"]  //List of Public subnet cidr range
private_subnets_cidr = ["10.0.10.0/24"] //List of private subnet cidr range

#public_subnets_cidr  = ["10.0.0.0/18", "10.0.64.0/18"]
#private_subnets_cidr = ["10.0.128.0/18", "10.0.192.0/18"]