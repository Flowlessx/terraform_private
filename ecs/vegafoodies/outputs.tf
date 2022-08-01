# outputs.tf

output "alb_vegafoodies_hostname" {
  value = aws_alb.vegafoodies.dns_name
}







