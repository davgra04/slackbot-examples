# Specify the provider and access details
provider "aws" {
  region = "us-west-2"
}

resource "aws_key_pair" "auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

####################################################################################################
##  INFRA (vpc, internet gateway, route table, subnet)
####################################################################################################

# Create a VPC to launch our instances into
resource "aws_vpc" "slackbots-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
      Name = "slackbots-VPC"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "slackbots-ig" {
  vpc_id = aws_vpc.slackbots-vpc.id
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.slackbots-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.slackbots-ig.id
}

# Create a subnet to launch our instances into
resource "aws_subnet" "slackbots-subnet" {
  vpc_id                  = aws_vpc.slackbots-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
}

####################################################################################################
##  SECURITY GROUPS
####################################################################################################

# The default security group to grant outbound Internet access and SSH from a
# single IP
resource "aws_security_group" "slackbots-default-sg" {
  name        = "slackbots-default-sg"
  description = "Default security group for axlist"
  vpc_id      = aws_vpc.slackbots-vpc.id

  # SSH access from my IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group which grants HTTP(S) access
resource "aws_security_group" "slackbots-http-sg" {
  name        = "slackbots-http-sg"
  description = "HTTP(S) security group for axlist"
  vpc_id      = aws_vpc.slackbots-vpc.id

  # HTTP access from my IP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from my IP
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group which grants 3000 access for Slack API integration
resource "aws_security_group" "slackbots-api-sg" {
  name        = "slackbots-api-sg"
  description = "Slack API security group for axlist"
  vpc_id      = aws_vpc.slackbots-vpc.id

  # HTTP access from my IP
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


####################################################################################################
##  EC2
####################################################################################################

# nginx load balancer instance
resource "aws_instance" "slackbots-instance" {
  connection {
    # type        = "ssh"
    user        = "centos"
    host        = self.public_ip
    private_key = file(var.private_key_path)
  }

  root_block_device {
    volume_size = 32
  }

  instance_type = var.instance_type
  ami = lookup(var.aws_amis, var.aws_region)
  key_name = aws_key_pair.auth.id
  subnet_id = aws_subnet.slackbots-subnet.id
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.slackbots-default-sg.id,
    aws_security_group.slackbots-http-sg.id,
    aws_security_group.slackbots-api-sg.id,
  ]

  tags = {
    Name = "slackbots-lb",
    Project = "axlist"
  }
}


####################################################################################################
##  Outputs
####################################################################################################

output "ssh_command" {
  value = "ssh -i \"${var.private_key_path}\" centos@${aws_instance.slackbots-instance.public_ip}"
}
