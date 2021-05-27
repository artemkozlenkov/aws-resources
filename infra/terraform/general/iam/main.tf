resource "aws_iam_instance_profile" "test_profile" {
  name = "test_cluster_profile"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "test_cluster_role"
  path = "/"

  assume_role_policy = <<EOF
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
EOF
}
