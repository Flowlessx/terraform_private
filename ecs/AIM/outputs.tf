# outputs.tf

output "alb_starcenter_hostname" {
  value = aws_alb.AIM.dns_name
}




