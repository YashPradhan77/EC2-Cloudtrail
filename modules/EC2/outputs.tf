output "alb_DNS_Name" {
  description = "The DNS name of the ALB"
  value = aws_lb.alb.dns_name
}
  