resource "aws_lb" "lb" {
  name_prefix        = "bsci"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id, aws_security_group.bsci.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_security_group" "lb" {
  name        = "lb-frontend-sg"
  description = "Allow inbound traffic to the LB"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP port 80 traffic"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS port 443 traffic"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http-80" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}

resource "aws_lb_target_group" "target-group" {
  port                 = 8080
  protocol             = "HTTP"
  target_type          = "instance"
  vpc_id               = aws_vpc.vpc.id
  deregistration_delay = "15"
  lifecycle {
    create_before_destroy = true
  }

  health_check {
    enabled  = true
    interval = 10
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  alb_target_group_arn   = aws_lb_target_group.target-group.arn
}