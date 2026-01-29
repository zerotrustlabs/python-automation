# output "public_ip_0" {
#   description = "public ec2 ip addres"
#   value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.ec2[0].public_ip}"
# }

output "loadbalancer" {
  description = "load balancer ip"
  value       = aws_lb.this.dns_name
}