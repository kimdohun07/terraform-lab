resource "aws_security_group" "auto_web_sg" {
  name        = "auto-web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_vpc.default.id

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

  tags = {
    Name = "auto-web-sg"
  }
}

resource "aws_instance" "auto_web1" {
  ami                         = data.aws_ssm_parameter.ami.value
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.auto_web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              dnf install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>Auto Web Server 1</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "auto-web1"
  }
}

resource "aws_instance" "auto_web2" {
  ami                         = data.aws_ssm_parameter.ami.value
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnets.default.ids[1]
  vpc_security_group_ids      = [aws_security_group.auto_web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              dnf install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo "<h1>Auto Web Server 2</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "auto-web2"
  }
}