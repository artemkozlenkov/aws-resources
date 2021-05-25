locals {
  name   = var.asg_name
  region = var.aws_region

  tags = [
    {
      key                 = "Project"
      value               = "self-hosted-discourse"
      propagate_at_launch = true
    }
  ]

  tags_as_map = {
    Owner       = "user"
    Environment = "test"
  }
}

data "aws_ami" "discourse" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["*discourse*"]
  }
}

data "aws_vpc" "cluster" {
  filter {
    name   = "tag:Name"
    values = ["cluster"]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.cluster.id
  filter {
    name   = "tag:Name"
    values = ["private*"]
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.cluster.id
  filter {
    name   = "tag:Name"
    values = ["public*"]
  }
}
################################################################################
# Supporting Resources
################################################################################
module "asg_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "~> 4.0"

  name        = local.name
  description = "A ${local.name} security group"
  vpc_id      = data.aws_vpc.cluster.id

  ingress_rules           = ["http-80-tcp", "ssh-tcp"]
  ingress_cidr_blocks              = ["0.0.0.0/0"]

  egress_rules = ["http-80-tcp"]
  egress_cidr_blocks              = ["0.0.0.0/0"]

  tags = local.tags_as_map
}

resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "A service linked role for autoscaling"
  custom_suffix    = local.name

  # Sometimes good sleep is required to have some IAM resources created before they can be used
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "aws_iam_instance_profile" "ssm" {
  name = "discourse-${local.name}"
  role = aws_iam_role.ssm.name
  tags = local.tags_as_map
}

resource "aws_iam_role" "ssm" {
  name = "discourse-${local.name}"
  tags = local.tags_as_map

  assume_role_policy = <<-EOT
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOT
}

module "alb_http_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "~> 4.0"

  name        = "${local.name}-alb-http"
  vpc_id      = data.aws_vpc.cluster.id
  description = "Security group for ${local.name}"

  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = local.tags_as_map
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = local.name

  vpc_id          = data.aws_vpc.cluster.id
  subnets         = data.aws_subnet_ids.public.ids
  security_groups = [module.alb_http_sg.security_group_id]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name             = local.name
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    },
  ]

  tags = local.tags_as_map
}

################################################################################
# Default
################################################################################

# Launch template
module "default_lt" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  # Autoscaling group
  name = "default-lt-${local.name}"

  security_groups = [module.asg_sg.security_group_id]

  vpc_zone_identifier = data.aws_subnet_ids.private.ids
  min_size            = 0
  max_size            = 1
  desired_capacity    = 1

  # Launch template
  use_lt    = true
  create_lt = true

  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  user_data   = <<-EOF
              #!/bin/bash
              sudo apt update; sudo apt upgrade -y; iptables -F; service sshd restart;
              echo "This is a test discourse-ec2-instance" > index.html
              sudo python3 -m http.server 80
              EOF
  key_name    = "dev"
  tags        = local.tags
  tags_as_map = local.tags_as_map
}
