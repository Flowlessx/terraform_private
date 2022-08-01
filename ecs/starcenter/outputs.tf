# outputs.tf

output "alb_starcenter_hostname" {
  value = aws_alb.starcenter.dns_name
}





