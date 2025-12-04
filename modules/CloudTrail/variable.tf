variable "trail_bucket_name" {
  description = "Name of the S3 bucket that CloudTrail will write to."
  type        = string
}

variable "multi_region" {
  description = "Whether the CloudTrail should be multi-region."
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Enable CloudTrail log file integrity validation."
  type        = bool
  default     = true
}

variable "ec2_termination_alert_email" {
  description = "Email address to receive EC2 termination alerts"
  type        = string
}

