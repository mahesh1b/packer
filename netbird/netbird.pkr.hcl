packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.6"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "netbird-43.02-ubuntu-aws"
  instance_type = "t4g.micro"
  region        = "us-east-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "Netbird Image Construction"

  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  # Stage 1: Docker Installation
  provisioner "ansible" {
    playbook_file = "./install-docker.yml"
  }

  # Stage 2: Netbird Installation
  provisioner "ansible" {
    playbook_file = "./install-netbird.yml"
  }

  # Cleanup after https://github.com/hashicorp/packer/issues/9118
  provisioner "shell" {
    inline = [
      "rm -rf /home/ubuntu/~mahesh"
    ]
  }

}
