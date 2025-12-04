variable "ec2_sg_name" {
  description = "Name of the security group for EC2 instances"
  type        = string
  default     = "ec2-security-group"
}

variable "alb_sg_name" {
  description = "Name of the security group for the ALB"
  type        = string
  default     = "alb-security-group"
}

variable "vpc_id" {
  description = "VPC ID where the security groups will be created"
  type        = string
}
