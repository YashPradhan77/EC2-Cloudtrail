output "alb_DNS_Name" {
  description = "The DNS name of the ALB"
  value       = module.ec2.alb_DNS_Name
}
  