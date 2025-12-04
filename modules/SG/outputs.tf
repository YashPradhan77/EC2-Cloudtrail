output "ec2_sg_id" {
  description = "The ID of the EC2 security group"
  value       = aws_security_group.ec2-sg.id
}

output "alb_sg_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb-sg.id
  
}
