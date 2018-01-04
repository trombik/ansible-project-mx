provider "aws" {
  region     = "ap-northeast-1"
}

resource "aws_key_pair" "terraform" {
  key_name = "terraform-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBSkBaRbF61+nc4SOy4+9PjWt0l5M/SJRlMoukSlQFxIjUgduOoBXXpquyz5TRxd0u8UEW0i99p3yf+PiY2Qs+52LIAsY8r7z2qeAj3WM7akbjozwpiukN4C55WQwfyJj7Seszpqv8RbbRkciuB/xJsllDlBgwKu34OOtEh8E9ezZueu/IenaB4uCtVKXG6WbE2xeeXl/qk9Sbf93plO7v45VgJyN4bwnIlscaOpvaJpoNRNntGECCCmjOP+FFf4Pxz5IrGhLjVXRAcgYsj2XHMiNUt9utj8VHGocBnembXERrhbGjoxw1U0Aka1BC+PrH6qnFPQgT4PIG+25gTMWr y@trombik.org"
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
  type = "string"
  default = "mx1.trombik.org"
}

module "instance" {
  source                        = "git::https://github.com/cloudposse/terraform-aws-ec2-instance.git?ref=0.7.0"
  ssh_key_pair                  = "${aws_key_pair.terraform.key_name}"
  instance_type                 = "t2.micro"
  ami                           = "ami-db1299bd"
  vpc_id                        = "vpc-7a87641e"
  subnet                        = "subnet-293b9c5f"
  assign_eip_address            = "false"
  name                          = "${replace(var.fqdn, "[.]", "_")}"
  namespace                     = "${module.project_yaml.result["name"]}"
  stage                         = "${var.stage}"
  allowed_ports                 = ["22", "25", "587"]
  tags                          = "${map("Name", var.fqdn, "Project", module.project_yaml.result["name"])}"
  root_volume_type              = "standard"
  user_data                     = "${file("${path.module}/openbsd_user_data.sh")}"
}
