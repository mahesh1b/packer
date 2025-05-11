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
  ami_name      = "ubuntu-24.04-linux-aws"
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
  name = "Configure Netbird"

  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  # Install docker and docker compose
  provisioner "ansible" {
    playbook_file = "./install-docker.yml"
  }

  # Get the Netibird code
  provisioner "ansible" {
    playbook_file = "./install-netbird.yml"
  }

  # Copy setup.env to the remote instance
  provisioner "file" {
    source      = "setup.env"
    destination = "/home/ubuntu/netbird/infrastructure_files/setup.env"
  }

}
