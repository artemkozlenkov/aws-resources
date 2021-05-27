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

  target_group_arns = data.terraform_remote_state.alb.outputs.target_group_arns

  vpc_zone_identifier = data.aws_subnet_ids.private.ids
  min_size            = 0
  max_size            = 1
  desired_capacity    = 1

  # Launch template
  use_lt    = true
  create_lt = true

  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  user_data = data.template_file.init.rendered

  key_name    = "dev"
  tags        = local.tags
  tags_as_map = local.tags_as_map
}
