# output "public_ip_0" {
#   description = "public ec2 ip addres"
#   value       = "ssh -i ~/.ssh/id_rsa ubuntu@${data.aws_instance.ft.public_ip}"
# }

output "loadbalancer" {
  description = "load balancer ip"
  value       = aws_lb.this.dns_name
}



output "account_id" {
  value = data.aws_caller_identity.current.account_id

}