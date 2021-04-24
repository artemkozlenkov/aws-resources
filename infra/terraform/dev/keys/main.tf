resource "aws_key_pair" "single_ec2_ssh_key" {
  public_key = file("~/.ssh/aws_private.pub")
  key_name = "dev"
}