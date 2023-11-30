data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data "aws_ami" "rhel-88-useast2" {
  owners = null
  filter {
    name = "image-id"
    values = ["ami-0aa311f5004442a57"]
  }

}