packer {
  required_version = ">= 1.5.4"
}

locals { timestamp = lower(regex_replace(timestamp(), "[- TZ:]", "")) }

variable "ubuntu_lts_base" {
  default = "ami-0767046d1677be5a0"
}

variable "instance_type" {
  default = "t3a.medium"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

source "amazon-ebs" "ubuntu20-ami" {
  ami_description = "An Ubuntu 20.04 AMI for Discourse ASG."
  ami_name        = "ubuntu-asg-discourse-${local.timestamp}"

  source_ami    = var.ubuntu_lts_base
  instance_type = var.instance_type
  region        = var.aws_region

  launch_block_device_mappings {
    device_name = "/dev/sda1"
    encrypted   = true
    volume_size = 20
  }

  ssh_username          = "ubuntu"
  force_delete_snapshot = true
}

build {
  sources = ["source.amazon-ebs.ubuntu20-ami"]

  provisioner "file" {
    source      = "./keys/github/github"
    destination = "~/.ssh/github"
  }

  provisioner "file" {
    source      = "./scripts/app.yml"
    destination = "~/app.yml"

  }

  provisioner "shell" {
    expect_disconnect = true
    script            = "./scripts/setup.sh"
  }

  provisioner "shell" {
    expect_disconnect = true
    script = "./scripts/after_restart.sh"
  }
}
