module "security_groups" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"

  name   = "ssh-group"
  vpc_id = data.aws_vpc.selected.id

  computed_ingress_rules           = ["ssh-tcp"]
  number_of_computed_ingress_rules = 1
  ingress_cidr_blocks              = [data.aws_vpc.selected.cidr_block]

  computed_egress_rules           = ["all-all"]
  number_of_computed_egress_rules = 1
  egress_cidr_blocks              = ["0.0.0.0/0"]
}

module "this" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.17.0"

  count = 1

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  name          = "gateway"
  user_data = <<-EOF
sudo apt update; sudo apt upgrade -y; iptables -F; service sshd restart;
EOF

  key_name                    = "dev"
  associate_public_ip_address = true

  vpc_security_group_ids = [module.security_groups.this_security_group_id]
  subnet_id              = data.aws_subnet_ids.public[0].id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
