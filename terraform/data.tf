# data "aws_instance" "ft" {
#   filter {
#     name   = "tag:aws:autoscaling:groupName"
#     values = [aws_autoscaling_group.asg.name]
#   }
#   # instance_state = ["running"]

#   depends_on = [aws_launch_template.this]
# }


data "aws_caller_identity" "current" {}

