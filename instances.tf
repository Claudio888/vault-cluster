data "aws_ami" "consul" {
  most_recent = true

  filter {
    name   = "name"
    values = ["consul-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"]
}

data "aws_ami" "vault" {
  most_recent = true

  filter {
    name   = "name"
    values = ["vault-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"]
}

resource "aws_instance" "consul" {
  count = var.cluster_machine_number
  ami           = data.aws_ami.consul.id
  instance_type = var.instance_type
  key_name = "consul"
  security_groups = [aws_security_group.instances_security_group.name]

  tags = {
    Name = "consul"
  }

}

resource "null_resource" "consul_config" {
  count = length(aws_instance.consul)

  triggers = {
    config_file = templatefile("${path.module}/templates/consul.tpl", {
      consul_address   = aws_instance.consul[count.index].private_ip
      consul_address1  = aws_instance.consul[0].private_ip
      consul_address2  = aws_instance.consul[1].private_ip
      consul_address3  = aws_instance.consul[2].private_ip
      index = "${count.index+1}"
    })
    always_run = "${timestamp()}"
  }

  provisioner "file" {
    content     = self.triggers.config_file
    destination = "/tmp/consul.json"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.consul[count.index].public_ip
      private_key = file("~/.ssh/consul.pem")
    }
  }

  provisioner "file" {
    source     = "${path.module}/templates/consul.service"
    destination = "/tmp/consul.service"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.consul[count.index].public_ip
      private_key = file("~/.ssh/consul.pem")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/consul.service /etc/systemd/system/consul.service",
      "sudo cp /tmp/consul.json /etc/consul/consul.json",
      "sudo chown consul:consul /etc/consul/consul.json",
      "sudo systemctl daemon-reload",
      "sudo systemctl start consul.service",
      "sudo systemctl enable consul.service"

    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.consul[count.index].public_ip
      private_key = file("~/.ssh/consul.pem")
    }
  }
}

resource "aws_instance" "vault" {
  count = var.cluster_machine_number
  ami           = data.aws_ami.vault.id
  instance_type = var.instance_type
  key_name = "consul"
  security_groups = [aws_security_group.instances_security_group.name]

  tags = {
    Name = "vault"
  }

}


resource "null_resource" "vault_config" {
  count = length(aws_instance.vault)

  triggers = {
    config_file_vault = templatefile("${path.module}/templates/vault.tpl", {
      vault_address   = aws_instance.vault[count.index].private_ip
    })
    config_file_consul_client = templatefile("${path.module}/templates/consul-client.tpl", {
      vault_address   = aws_instance.vault[count.index].private_ip
      consul_address1  = aws_instance.consul[0].private_ip
      consul_address2  = aws_instance.consul[1].private_ip
      consul_address3  = aws_instance.consul[2].private_ip
      index = "${count.index+1}"
    })
    always_run = "${timestamp()}"
  }

  provisioner "file" {
    content     = self.triggers.config_file_vault
    destination = "/tmp/config.hcp"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.vault[count.index].public_ip
      private_key = file("~/.ssh/consul.pem")
    }
  }

  provisioner "file" {
    content     = self.triggers.config_file_consul_client
    destination = "/tmp/consul.json"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.vault[count.index].public_ip
      private_key = file("~/.ssh/consul.pem")
    }
  }

  provisioner "file" {
    source     = "${path.module}/templates/vault.service"
    destination = "/tmp/vault.service"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.vault[count.index].public_ip
      private_key = file("~/.ssh/consul.pem")
    }
  }

  provisioner "file" {
    source     = "${path.module}/templates/consul.service"
    destination = "/tmp/consul.service"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.vault[count.index].public_ip
      private_key = file("~/.ssh/consul.pem")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/consul.service /etc/systemd/system/consul.service",
      "sudo cp /tmp/consul.json /etc/consul/consul.json",
      "sudo chown consul:consul /etc/consul/consul.json",
      "sudo cp /tmp/config.hcp /etc/vault/config.hcl",
      "sudo cp /tmp/vault.service /etc/systemd/system/vault.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl start consul.service",
      "sudo systemctl enable consul.service",
      "sudo systemctl start vault.service",
      "sudo systemctl enable vault.service"

    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.vault[count.index].public_ip
      private_key = file("~/.ssh/consul.pem")
    }
  }
}