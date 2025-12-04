# Tags 
variable "tags" {
  description = "A map of tags to assign to resources"
}

variable "region" {
  description = "AWS region"
  type        = string
}

# VPC
variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
}

variable "vpc_azs" {
  description = "Availability zones for the VPC"
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "vpc_private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "vpc_enable_nat_gateway" {
  description = "Whether to enable NAT Gateway"
  type        = bool
}

variable "vpc_single_nat_gateway" {
  description = "Use a single NAT Gateway"
  type        = bool
}

variable "vpc_one_nat_gateway_per_az" {
  description = "One NAT Gateway per AZ"
  type        = bool
}

# EC2
variable "ec2_instance_name" {
  description = "EC2 instance name"
  type        = string
}

variable "ec2_ami" {
  description = "EC2 AMI ID"
  type        = string
}

variable "volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
}
variable "volume_type" {
  description = "Type of the root EBS volume"
  type        = string
}
variable "encrypted" {
  description = "Whether the root EBS volume should be encrypted"
  type        = bool
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ec2_associate_public_ip" {
  description = "Associate public IP to EC2"
  type        = bool
}

# Security groups
variable "sg_ec2_name" {
  description = "EC2 security group name"
  type        = string
}

variable "sg_alb_name" {
  description = "ALB security group name"
  type        = string
}

# ALB
variable "alb_name" {
  description = "ALB name"
  type        = string
}

variable "alb_internal" {
  description = "Whether ALB is internal"
  type        = bool
}

variable "alb_type" {
  description = "ALB type (application/network)"
  type        = string
}

variable "alb_enable_deletion_protection" {
  description = "Enable ALB deletion protection"
  type        = bool
}

# ALB Target Group
variable "tg_name" {
  description = "Target group name"
  type        = string
}

variable "tg_port" {
  description = "Target group port"
  type        = number
}

variable "tg_protocol" {
  description = "Target group protocol"
  type        = string
}

variable "tg_target_type" {
  description = "Target group target type"
  type        = string
}

variable "tg_deregistration_delay" {
  description = "Deregistration delay seconds for target group"
  type        = number
}

# ALB Health Check
variable "hc_path" {
  description = "Health check path"
  type        = string
}

variable "hc_protocol" {
  description = "Health check protocol"
  type        = string
}

variable "hc_matcher" {
  description = "Health check matcher (e.g. 200)"
  type        = string
}

variable "hc_interval" {
  description = "Health check interval seconds"
  type        = number
}

variable "hc_timeout" {
  description = "Health check timeout seconds"
  type        = number
}

variable "hc_healthy_threshold" {
  description = "Health check healthy threshold"
  type        = number
}

variable "hc_unhealthy_threshold" {
  description = "Health check unhealthy threshold"
  type        = number
}

# ALB Listener
variable "listener_port" {
  description = "ALB listener port"
  type        = number
}

variable "listener_protocol" {
  description = "ALB listener protocol"
  type        = string
}

variable "listener_default_action_type" {
  description = "Listener default action type"
  type        = string
}

variable "listener_default_target_group_arn" {
  description = "Listener default target group ARN"
  type        = string
}

variable "listener_extra_actions" {
  description = "Extra listener actions"
  type        = list(any)
}

# CloudTrail
variable "cloudtrail_bucket_name" {
  description = "CloudTrail S3 bucket name"
  type        = string
}

variable "cloudtrail_multi_region" {
  description = "CloudTrail multi-region setting"
  type        = bool
}

variable "cloudtrail_enable_log_file_validation" {
  description = "CloudTrail log file validation"
  type        = bool
}

variable "ec2_termination_alert_email" {
  description = "Email address to receive EC2 termination alerts"
  type        = string
}