terraform {
  required_version = " >= 0.12.0"
}

provider "aws" {
  region                  = var.aws_region
  profile                 = var.aws_profile
  shared_credentials_file = "~/.aws/credentials"
}

resource "random_id" "instance_id" {
  byte_length = 4
}

data "aws_ami" "ubuntu1804" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# ////////////////////////////////
# // Ubuntu 18.04 Instance

resource "aws_instance" "ubuntu1804" {
	connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.aws_ubuntu_image_user
    private_key = file(var.aws_key_pair_file)
  }

  ami                         = data.aws_ami.ubuntu1804.id
  instance_type               = var.instance_type
  key_name                    = var.aws_key_pair_name
  subnet_id                   = aws_subnet.go_redis_reader_subnet.id
  vpc_security_group_ids      = ["${aws_security_group.go_redis_reader_sg.id}"]
  associate_public_ip_address = true
  count                       = var.ubuntu1804_count

  tags = {
    Name          = "${var.tag_name}_ubuntu1804_${random_id.instance_id.hex}"
    X-Dept        = var.tag_dept
    X-Customer    = var.tag_customer
    X-Project     = var.tag_project
    X-Application = var.tag_application
    X-Contact     = var.tag_contact
    X-TTL         = var.tag_ttl
  }

	provisioner "file" {
		source = "files/startup.sh"
		destination = "/tmp/startup.sh"
	}

  provisioner "remote-exec" {
    inline = [
      "sudo hostname ubuntu1804-lacework",
      "curl ${var.lacework_agent_url} | sudo bash",
      "sudo chmod +x /tmp/startup.sh",
      "sudo /tmp/startup.sh",
    ]
  }
}

////////////////////////////////
// VPC

resource "aws_vpc" "go_redis_reader_vpc" {
  cidr_block = "10.0.0.0/16"

  tags  = {
    Name          = "${var.tag_name}_vpc"
    X-Dept        = var.tag_dept
    X-Customer    = var.tag_customer
    X-Project     = var.tag_project
    X-Contact     = var.tag_contact
    X-Application = var.tag_application
    X-TTL         = var.tag_ttl
  }
}

resource "aws_internet_gateway" "go_redis_reader_gateway" {
  vpc_id = aws_vpc.go_redis_reader_vpc.id

  tags = {
    Name = "go_redis_reader_gateway_${random_id.instance_id.hex}"
  }
}

resource "aws_route" "lw_internet_access" {
  route_table_id         = aws_vpc.go_redis_reader_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.go_redis_reader_gateway.id
}

resource "aws_subnet" "go_redis_reader_subnet" {
  vpc_id                  = aws_vpc.go_redis_reader_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "go_redis_reader_subnet_${random_id.instance_id.hex}"
  }
}

resource "aws_security_group" "go_redis_reader_sg" {
  name        = "go_redis_reader_sg_${random_id.instance_id.hex}"
  description = "Security group provisioned by Terraform template project"
  vpc_id      = aws_vpc.go_redis_reader_vpc.id

  tags = {
    Name          = "go_redis_reader_security_group_${var.tag_name}_${random_id.instance_id.hex}"
    X-Dept        = var.tag_dept
    X-Customer    = var.tag_customer
    X-Project     = var.tag_project
    X-Application = var.tag_application
    X-Contact     = var.tag_contact
    X-TTL         = var.tag_ttl
  }
}

//////////////////////////
// SG Rules
resource "aws_security_group_rule" "ingress_allow_22_tcp_all" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.go_redis_reader_sg.id
}

resource "aws_security_group_rule" "ingress_allow_443_tcp_all" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.go_redis_reader_sg.id
}

resource "aws_security_group_rule" "ingress_allow_80_tcp_all" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.go_redis_reader_sg.id
}

resource "aws_security_group_rule" "ingress_allow_6379_tcp_all" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.go_redis_reader_sg.id
}

# Egress: ALL
resource "aws_security_group_rule" "linux_egress_allow_0-65535_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.go_redis_reader_sg.id
}
