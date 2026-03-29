data "aws_security_group" "common_sg" {
  vpc_id = local.vpc.vpc_id

  filter {
    name = "group-name"
    values = ["default"]
  }
}


locals {
  common_sg_id = data.aws_security_group.common_sg.id

  nodes = {
    instance_type = "t3.micro"
    ami           = "ami-0a71e3eb8b23101ed"
  }

  ingress = {
    "all" = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["169.254.171.0/24"]
    },
    "ssh"= {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks= ["220.86.168.26/32"]
    },
    "http" = {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks= ["220.86.168.26/32"]
    }
  }

  egress = {
    "all" = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

module "nodes" {
  source = "github.com/leedonggyu-terraform-factory/terraform-resource-ec2?ref=master"

  items = {
    "service-input" = {
      instance_type               = local.nodes.instance_type
      ami                         = local.nodes.ami
      vpc_id                      = local.vpc.vpc_id
      subnet_id                   = local.vpc.webserver_subnet_ids["a"]
      associate_public_ip_address = true
      user_data                   = file("scripts/docker.sh")
      common_sg_id                = null
      key_name                    = "ec2-keypair"

      ingress = local.ingress
      egress  = local.egress
    }
  }
}

resource "null_resource" "uc_init" {

  provisioner "local-exec" {
    command = "./scripts/uc_init.sh ${module.nodes.ec2_public_ip.service-input}"
  }

  depends_on = [module.nodes]
}
