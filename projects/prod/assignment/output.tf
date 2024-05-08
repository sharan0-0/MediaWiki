output "Bastion-IP" {
  description = "This is the  Bastion-IP to access Application Server"
  value       = module.bastion.public_ip
}

output "AppServer-IP" {
  description = "This Ip is of Application Server"
  value       = module.ec2.private_ip
}

output "ALB-DNS" {
  description = "Open This DNS in Browser To access Application"
  value       = module.alb.dns_name
}
