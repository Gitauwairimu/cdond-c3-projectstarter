terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = ">= 4.0"
        }
    } 
}

provider "aws" {
    region = "us-east-1"
    access_key = "AKIAU5346P2ZZJSLKTNE"
    secret_key = "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"
    # access_key = "$access_key"
    # secret_key = "$secret_key"
}

resource "aws_instance" "prometheus-server" {
    ami = "ami-08d4ac5b634553e16" #ubuntu 20.04 LTS // us-east-1
    instance_type = "t2.micro"

  # vpc_security_group_ids = [
  #   aws_security_group.prometheus-iac-sg.id
  # ]
#   root_block_device {
#     delete_on_termination = true
#     iops = 150
#     volume_size = 50
#     volume_type = "gp2"
#  }
  tags = {
    Name ="Prometheus Server"
    OS = "UBUNTU"
    Managed = "IAC"
  }

  depends_on = [ aws_security_group.prometheus-iac-sg ]
}



resource "aws_security_group" "prometheus-iac-sg" {
  name = "prometheus-iac-sg"
  description = "Terraform Provisioned"
  #vpc_id = lookup(var.awsprops, "vpc")

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
