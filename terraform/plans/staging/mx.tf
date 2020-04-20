provider "aws" {
  region     = "ap-northeast-1"
}

module "project_yaml" {
  name = "project"
  source = "../../modules/yaml"
  path = "project.yml"
}

# can be overrided by TF_VAR_stage environment variable
variable "stage" {
  default = "staging"
}

variable "fqdn" {
  type = string
  default = "mx1.trombik.org"
}

module "instance" {
  source                        = "git::https://github.com/cloudposse/terraform-aws-ec2-instance.git?ref=0.17.0"
  ssh_key_pair                  = "terraform-key"
  instance_type                 = "t2.micro"

  # the AMI was built with:
  # https://github.com/ajacoutot/aws-openbsd
  ami                           = "ami-04af7ec1b9ea369dd"
  ami_owner                     = "227373499457"
  vpc_id                        = "vpc-7a87641e"
  subnet                        = "subnet-293b9c5f"
  assign_eip_address            = "false"
  name                          = "${replace(var.fqdn, "[.]", "_")}"
  namespace                     = "${module.project_yaml.result["name"]}"
  stage                         = "${var.stage}"
  allowed_ports                 = ["22", "25", "587", "993"]
  tags                          = "${map("Name", var.fqdn, "Project", module.project_yaml.result["name"])}"
  root_volume_type              = "standard"
  root_volume_size              = "12"
  user_data                     = "${file("${path.module}/openbsd_user_data.sh")}"
}
