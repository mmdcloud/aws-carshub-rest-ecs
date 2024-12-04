# Load Balancer Creation
resource "aws_lb" "lb" {
  name                       = "lb"
  internal                   = false
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.security_group.id]
  subnets                    = aws_subnet.public_subnets[*].id
  enable_deletion_protection = false
  tags = {
    Name = "lb"
  }
}

# Creating a Target Group
resource "aws_lb_target_group" "lb_target_group" {
  name            = "lb-target-group"
  port            = 8080
  ip_address_type = "ipv4"
  protocol        = "HTTP"
  target_type     = "ip"
  vpc_id          = aws_vpc.vpc.id

  health_check {
    interval            = 30
    path                = "/"
    enabled             = true
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    port                = 80
  }

  tags = {
    Name = "lb_target_group"
  }
}

# Creating a Load Balancer listener
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

resource "aws_lb_listener" "https_lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.carshub_cert_validate.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

# Load Balancer Creation
resource "aws_lb" "frontend-lb" {
  name                       = "frontend-lb"
  internal                   = false
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.security_group.id]
  subnets                    = aws_subnet.public_subnets[*].id
  enable_deletion_protection = false
  tags = {
    Name = "frontend-lb"
  }
}

# Creating a Target Group
resource "aws_lb_target_group" "frontend_lb_target_group" {
  name            = "frontend-lb-target-group"
  port            = 3000
  ip_address_type = "ipv4"
  protocol        = "HTTP"
  target_type     = "ip"
  vpc_id          = aws_vpc.vpc.id

  health_check {
    interval            = 30
    path                = "/"
    enabled             = true
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    port                = 80
  }

  tags = {
    Name = "frontend_lb_target_group"
  }
}

# Creating a Load Balancer listener
resource "aws_lb_listener" "frontend_lb_listener" {
  load_balancer_arn = aws_lb.frontend-lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_lb_target_group.arn
  }
}

resource "aws_lb_listener" "https_frontend_lb_listener" {
  load_balancer_arn = aws_lb.frontend-lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.carshub_cert_validate.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_lb_target_group.arn
  }
}