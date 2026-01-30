resource "aws_lb" "this" {
  #   availability_zone_id = data.aws_availability_zones.zone_ids
  security_groups = [aws_security_group.alb_sg.id]
  #   subnets = [aws_subnet.public_subnet.*.id[0], aws_subnet.public_subnet.*.id[1]]
  internal           = false
  load_balancer_type = "application"
  subnets            = [for subnets in aws_subnet.public_subnet : subnets.id]
  depends_on         = [aws_subnet.public_subnet]
}

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.this.id
  ingress {
    to_port     = 80
    from_port   = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [for subnet in aws_subnet.public_subnet : subnet.cidr_block]
  }
  tags = {
    environment = "dev"
    route       = "public"
    resource    = "load balancer"
  }

}

resource "aws_lb_listener" "lst" {
  load_balancer_arn = aws_lb.this.arn
  protocol          = "HTTP"
  port              = "80"
  # priority = 100
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
resource "aws_lb_target_group" "tg" {
  vpc_id = aws_vpc.this.id
  # target_type = "instance"
  port     = "8080"
  protocol = "HTTP"
  health_check {
    protocol            = "HTTP"
    path                = "/"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# resource "aws_lb_target_group_attachment" "test" {
#   count = 2
#   target_group_arn = aws_lb_target_group.tg.arn
#   target_id        = aws_instance.ec2[count.index].id
#   port             = 8080
# }

# resource "aws_lb_target_group_attachment" "test" {
#   target_group_arn = aws_lb_target_group.tg.arn
#   target_id        = aws_instance.ec2[count.index].id
#   port             = 8080
# }

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_lb_target_group.tg.arn
}