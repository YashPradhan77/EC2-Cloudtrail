variable "ec2_ami" {
  description = "AMI ID used for the EC2 instance"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
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

variable "ec2_subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = list(string)
  default     = []

}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "WebServerInstance"
}

variable "associate_public_ip" {
  description = "Whether to associate a public IP address with the EC2 instance"
  type        = bool
}

variable "vpc_id" {
  description = "VPC ID where the EC2 instance will be launched"
  type        = string  
}

variable "internal" {
  description = "Whether the ALB is internal (true) or internet-facing (false)."
  type        = bool
  default     = false
}

variable "load_balancer_type" {
  description = "Load balancer type. For ALB use \"application\"."
  type        = string
  default     = "application"
  validation {
    condition     = contains(["application","network","gateway"], lower(var.load_balancer_type))
    error_message = "load_balancer_type must be one of: application, network, gateway."
  }
}

variable "alb_security_groups" {
  description = "List of security group IDs to attach to the ALB."
  type        = list(string)
  default     = []
}

variable "ec2_security_groups" {
  description = "List of security group IDs to attach to the EC2."
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "List of subnet IDs where the ALB will be placed (typically public subnets)."
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection for the ALB."
  type        = bool
  default     = false
}

variable "alb_name" {
  description = "Name of the Application Load Balancer."
  type        = string
  default     = "my-alb"  
  
}

variable "tg_name" {
  description = "Target group name (will be truncated to provider limits if necessary)."
  type        = string
  default     = "alb-tg"
}

variable "tg_port" {
  description = "Target group port."
  type        = number
  default     = 80
}

variable "tg_protocol" {
  description = "Target group protocol (HTTP, HTTPS, TCP, TLS)."
  type        = string
  default     = "HTTP"
  validation {
    condition     = contains(["HTTP","HTTPS","TCP","TLS","UDP","UDP_STREAM"], upper(var.tg_protocol))
    error_message = "tg_protocol must be one of HTTP, HTTPS, TCP, TLS, UDP, UDP_STREAM."
  }
}

variable "target_type" {
  description = "Target type for the target group (instance | ip | lambda)."
  type        = string
  default     = "ip"
  validation {
    condition     = contains(["instance","ip","lambda"], lower(var.target_type))
    error_message = "target_type must be one of: instance, ip, lambda."
  }
}

variable "deregistration_delay" {
  description = "Deregistration delay (seconds) for targets in the target group."
  type        = number
  default     = 30
}

# Health check block as an object to keep fields grouped and typed.
variable "health_check" {
  description = "Health check configuration for the target group."
  type = object({
    path                = string
    protocol            = string
    matcher             = string
    interval            = number
    timeout             = number
    healthy_threshold   = number
    unhealthy_threshold = number
  })
}

variable "listener_port" {
  description = "Listener port for the ALB listener."
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Listener protocol (HTTP or HTTPS)."
  type        = string
  default     = "HTTP"
  validation {
    condition     = contains(["HTTP","HTTPS"], upper(var.listener_protocol))
    error_message = "listener_protocol must be HTTP or HTTPS."
  }
}

variable "default_action_type" {
  description = "Default action type for the listener. Common value: forward."
  type        = string
  default     = "forward"
}

variable "default_target_group_arn" {
  description = "ARN of the target group used in the listener default action. If not provided the module should wire the created TG ARN."
  type        = string
  default     = ""
}

variable "extra_listener_actions" {
  description = "Optional list of additional listener actions/blocks (structure depends on usage). Use for advanced routing rules."
  type        = list(any)
  default     = []
}
