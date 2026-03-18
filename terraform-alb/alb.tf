provider "aws" {
  region = "us-west-1"
}

data "aws_vpc" "do_vpc" {
  filter {
    name   = "tag:Name"
    values = ["do-vpc"]
  }
}

data "aws_subnet" "public_a" {
  filter {
    name   = "tag:Name"
    values = ["do-public-subnet-a"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.do_vpc.id]
  }
}

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

data "aws_instance" "tf_web2" {
  filter {
    name   = "tag:Name"
    values = ["tf-web2"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.do_vpc.id]
  }
}

data "aws_instance" "existing_web2" {
  filter {
    name   = "tag:Name"
    values = ["do-public-web-2"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.do_vpc.id]
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "tf-alb-sg"
  description = "Security group for Terraform ALB"
  vpc_id      = data.aws_vpc.do_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_lb" "web_alb" {
  name               = "tf-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
    data.aws_subnet.public_a.id,
    data.aws_subnet.public_b.id
  ]

  tags = {
    Name = "tf-web-alb"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "tf-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.do_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "tf-web-tg"
  }
}

resource "aws_lb_target_group_attachment" "tf_web2_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = data.aws_instance.tf_web2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "existing_web2_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = data.aws_instance.existing_web2.id
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.web_alb.dns_name
}