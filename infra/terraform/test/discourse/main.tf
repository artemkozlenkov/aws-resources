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

################################################################################
# Supporting Resources
################################################################################
module "asg_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "~> 4.0"

  name        = local.name
  description = "A ${local.name} security group"
  vpc_id      = data.aws_vpc.cluster.id

  ingress_rules       = ["http-80-tcp", "ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["http-80-tcp"]
  egress_cidr_blocks = ["0.0.0.0/0"]

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

  target_group_arns = data.terraform_remote_state.alb.all.arns

  vpc_zone_identifier = data.aws_subnet_ids.private.ids
  min_size            = 0
  max_size            = 1
  desired_capacity    = 1

  # Launch template
  use_lt    = true
  create_lt = true

  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name    = "dev"
  tags        = local.tags
  tags_as_map = local.tags_as_map
}
