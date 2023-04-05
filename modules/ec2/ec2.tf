resource "aws_instance" "web-server" {
  ami           = var.ami
  instance_type = var.instance_type
  count 	= var.instance_count
  subnet_id     = var.pub_sub_id
  associate_public_ip_address = true
  security_groups = var.secgrp
}

