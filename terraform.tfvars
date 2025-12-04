tags = {
  Environment = "Dev"
  Project     = "Demo"
  ManagedBy   = "Terraform"
}

region = "us-west-1"

vpc_name                   = "main-vpc"
vpc_cidr_block             = "10.0.0.0/16"
vpc_azs                    = ["us-west-1a", "us-west-1c"]
vpc_public_subnets         = ["10.0.1.0/24", "10.0.2.0/24"]
vpc_private_subnets        = ["10.0.11.0/24", "10.0.12.0/24"]
vpc_enable_nat_gateway     = true
vpc_single_nat_gateway     = true
vpc_one_nat_gateway_per_az = false

volume_size = 20
volume_type = "gp3"
encrypted   = true

ec2_instance_name       = "app-ec2"
ec2_ami                 = "ami-03978d951b279ec0b"
ec2_instance_type       = "t3.micro"
ec2_associate_public_ip = false

sg_ec2_name = "ec2-sg"
sg_alb_name = "alb-sg"

alb_name                       = "ec2-alb"
alb_internal                   = false
alb_type                       = "application"
alb_enable_deletion_protection = false

tg_name                 = "alb-tg"
tg_port                 = 80
tg_protocol             = "HTTP"
tg_target_type          = "instance"
tg_deregistration_delay = 30

hc_path                = "/"
hc_protocol            = "HTTP"
hc_matcher             = "200"
hc_interval            = 30
hc_timeout             = 5
hc_healthy_threshold   = 2
hc_unhealthy_threshold = 2

listener_port                     = 80
listener_protocol                 = "HTTP"
listener_default_action_type      = "forward"
listener_default_target_group_arn = ""
listener_extra_actions            = []

cloudtrail_bucket_name                = "uehrwuejrnwejnfejw97723t6"
cloudtrail_multi_region               = true
cloudtrail_enable_log_file_validation = true
ec2_termination_alert_email = ""