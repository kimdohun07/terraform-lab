provider "aws" {
  region = "us-west-1"
}

# 최신 Amazon Linux 2023 AMI 조회
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# 기존 VPC 조회
data "aws_vpc" "do_vpc" {
  filter {
    name   = "tag:Name"
    values = ["do-vpc"]
  }
}

# 기존 Public Subnet 조회
data "aws_subnet" "public_b" {
  filter {
    name   = "tag:Name"
    values = ["do-public-subnet-b"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.do_vpc.id]
  }
}

# Security Group 생성
resource "aws_security_group" "web2_sg" {
  name        = "tf-web2-sg"
  description = "Security group for Terraform Web2"
  vpc_id      = data.aws_vpc.do_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 생성 (Terraform 인스턴스)
resource "aws_instance" "web2" {
  ami                         = data.aws_ssm_parameter.ami.value
  instance_type               = "t3.medium"   # ← 여기 변경됨
  subnet_id                   = data.aws_subnet.public_b.id
  vpc_security_group_ids      = [aws_security_group.web2_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              dnf install nginx -y
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>Terraform Web2</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "tf-web2"
  }
}

# Public IP 출력
output "web2_public_ip" {
  value = aws_instance.web2.public_ip
}