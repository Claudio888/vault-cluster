packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "vault" {
  ami_name      = "vault-{{timestamp}}"
  instance_type = "t3a.nano"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230516"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  profile = "default"
  ssh_username = "ubuntu"
}

build {
  name    = "vault-builder"
  sources = [
    "source.amazon-ebs.vault"
  ]

  provisioner "shell" {
    script = "./install-vault.sh"
  }
}