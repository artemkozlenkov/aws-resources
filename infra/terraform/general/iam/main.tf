locals {
  name   = "discourse-asg"
  region = var.aws_region

  tags_as_map = {
    Owner       = "user"
    Environment = "test"
  }
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
