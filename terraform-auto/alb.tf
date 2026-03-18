resource "aws_security_group" "auto_alb_sg" {
  name        = "auto-alb-sg"
  description = "Allow HTTP to ALB"
  vpc_id      = data.aws_vpc.default.id

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

  tags = {
    Name = "auto-alb-sg"
  }
}

resource "aws_lb" "auto_web_alb" {
  name               = "auto-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.auto_alb_sg.id]
  subnets            = data.aws_subnets.default.ids

  tags = {
    Name = "auto-web-alb"
  }
}

resource "aws_lb_target_group" "auto_web_tg" {
  name     = "auto-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

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
    Name = "auto-web-tg"
  }
}

resource "aws_lb_target_group_attachment" "auto_web1_attach" {
  target_group_arn = aws_lb_target_group.auto_web_tg.arn
  target_id        = aws_instance.auto_web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "auto_web2_attach" {
  target_group_arn = aws_lb_target_group.auto_web_tg.arn
  target_id        = aws_instance.auto_web2.id
  port             = 80
}

resource "aws_lb_listener" "auto_http" {
  load_balancer_arn = aws_lb.auto_web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auto_web_tg.arn
  }
}