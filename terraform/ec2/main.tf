######################################################################
### This TF file sets up an EC2 instance and a Security group        #
######################################################################

terraform {
  required_version = ">= 0.11.10"
}

provider "aws" {
  version = "~> 2.7"

  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}


##################
### Access key ###
##################

resource "aws_key_pair" "ssh_key_pair" {

  key_name	  = "aws_key"
  public_key      = var.ssh_public_key
}

###################
### Worker Node ###
###################

resource "aws_instance" "worker_node" {
  count                       = "1"
  ami                         = var.worker_node_config["ami"]
  instance_type               = var.worker_node_config["instance"]
  key_name		              = var.ssh_public_key == "" ? var.key_pair_name : join("", aws_key_pair.ssh_key_pair.*.key_name)
  vpc_security_group_ids      = [aws_security_group.worker_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = var.worker_node_config["root_volume_size"]
  }

  provisioner "file" {
    source      = "setup.sh"
    destination = "/tmp/setup.sh"

    connection {
      type = "ssh"
      user = "ubuntu"
      host = aws_instance.worker_node.0.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh"
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      host = aws_instance.worker_node.0.public_ip
    }
  }

  tags = {
           Name = "sams_workers"
         }
}


##################
### Networking ###
##################

# Worker security group
resource "aws_security_group" "worker_sg" {
  name        = "worker_sgroup"
  description = "Allow certain inbound and all outbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # Allow all tcp for Flask web server
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    # allow all outbound traffic
    # this could be more secure . . .
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


###################
### Output IPs ###
###################

output "vpn_public_ip" {
  value = zipmap(aws_instance.worker_node.*.public_dns, aws_instance.worker_node.*.public_ip)
}