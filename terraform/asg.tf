resource "aws_launch_configuration" "bsci" {
  name_prefix                 = "bsci"
  image_id                    = var.ami_id
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.bsci.id]
  associate_public_ip_address = false
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = aws_launch_configuration.bsci.name
  max_size                  = 6
  min_size                  = 3
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 3
  force_delete              = false
  launch_configuration      = aws_launch_configuration.bsci.name
  vpc_zone_identifier       = aws_subnet.public[*].id
  target_group_arns         = [aws_lb_target_group.target-group.arn]

  lifecycle {
    create_before_destroy = true
  }

}

# resource "aws_security_group" "allow-out" {
#   name        = "allow_out"
#   description = "allow web traffic out"
#   vpc_id      = var.vpc_id

#   egress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


resource "aws_security_group" "bsci" {
  name        = "benchsci-webservers"
  description = "benchsci security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["104.154.0.0/15"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
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
