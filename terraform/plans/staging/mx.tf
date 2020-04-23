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

variable "ports_tcp_public" {
  type = list(number)
  default = [22, 25, 53, 80, 443, 587, 993]
}

variable "ports_udp_public" {
  type = list(number)
  default = [53]
}


resource "aws_security_group" "mx" {
  name                          = "security_group_mx"
  description                   = "Security group for MX host in project MX"
  vpc_id                        = "vpc-7a87641e"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.ports_tcp_public
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "ingress" {
    for_each = var.ports_udp_public
    iterator = udp_port
    content {
      from_port = udp_port.value
      to_port   = udp_port.value
      protocol  = "udp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mx" {
  key_name                      = "terraform-key"
  instance_type                 = "t2.micro"
  ami                           = "ami-04af7ec1b9ea369dd"
  vpc_security_group_ids        = ["${aws_security_group.mx.id}"]
  subnet_id                     = "subnet-293b9c5f"
  tags                          = { "Name" = var.fqdn, "Project" = module.project_yaml.result["name"], "Stage" = var.stage }
  user_data                     = file("${path.module}/openbsd_user_data.sh")
  root_block_device {
    delete_on_termination = false
    volume_type = "standard"
    volume_size = 12
  }
}
