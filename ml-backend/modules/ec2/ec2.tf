data "aws_vpc" "pw_vpc" {
  filter {
    name   = "tag:Name"
    values = ["pw-vpc-${var.env}"]
  }
}

data "aws_subnet" "private_subnet_az1" {
  filter {
    name   = "tag:Name"
    values = ["pw-private-subnet-az1-${var.env}"]
  }
}

data "aws_subnet" "private_subnet_az2" {
  filter {
    name   = "tag:Name"
    values = ["pw-private-subnet-az2-${var.env}"]
  }
}

resource "tls_private_key" "pwmy_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "pwmy_ec2_key_pair" {
  key_name = "pwmy_ec2_key_pair"
  public_key = tls_private_key.pwmy_key.public_key_openssh
  tags = var.tags
}

resource "aws_security_group" "pwmy_ec2_security_group" {
  name        = var.ec2_security_group_name
  description = "Allow TLS inbound traffic"
  vpc_id = data.aws_vpc.pw_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_instance" "pwmy_ec2_instance" {
  ami             = var.ec2_ami
  instance_type   = var.ec2_instance_type
  key_name        = aws_key_pair.pwmy_ec2_key_pair.key_name
  subnet_id  = data.aws_subnet.private_subnet_az1.id

  vpc_security_group_ids = [aws_security_group.pwmy_ec2_security_group.id]

  tags = var.tags
}
