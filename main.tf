module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr_block

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway     = var.vpc_enable_nat_gateway
  single_nat_gateway     = var.vpc_single_nat_gateway
  one_nat_gateway_per_az = var.vpc_one_nat_gateway_per_az
}

module "flow_log" {
  source = "terraform-aws-modules/vpc/aws//modules/flow-log"

  name   = "cloudwatch-flow-log"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source = "./modules/EC2"

  # EC2 Module Variables
  instance_name     = var.ec2_instance_name
  ec2_ami           = var.ec2_ami
  ec2_instance_type = var.ec2_instance_type
  ec2_subnet_id       = module.vpc.private_subnets
  ec2_security_groups = [module.sg.ec2_sg_id]
  associate_public_ip = var.ec2_associate_public_ip

  volume_type = var.volume_type
  volume_size = var.volume_size
  encrypted   = var.encrypted
  # Networking
  vpc_id              = module.vpc.vpc_id
  subnets             = module.vpc.public_subnets
  alb_security_groups = [module.sg.alb_sg_id]

  # ALB module Variables
  alb_name                   = var.alb_name
  internal                   = var.alb_internal
  load_balancer_type         = var.alb_type
  enable_deletion_protection = var.alb_enable_deletion_protection

  # TG
  tg_name              = var.tg_name
  tg_port              = var.tg_port
  tg_protocol          = var.tg_protocol
  target_type          = var.tg_target_type
  deregistration_delay = var.tg_deregistration_delay

  health_check = {
    path                = var.hc_path
    protocol            = var.hc_protocol
    matcher             = var.hc_matcher
    interval            = var.hc_interval
    timeout             = var.hc_timeout
    healthy_threshold   = var.hc_healthy_threshold
    unhealthy_threshold = var.hc_unhealthy_threshold
  }

  # Listener
  listener_port            = var.listener_port
  listener_protocol        = var.listener_protocol
  default_action_type      = var.listener_default_action_type
  default_target_group_arn = var.listener_default_target_group_arn
  extra_listener_actions   = var.listener_extra_actions
}

module "sg" {
  source = "./modules/SG"

  vpc_id      = module.vpc.vpc_id
  ec2_sg_name = var.sg_ec2_name
  alb_sg_name = var.sg_alb_name
}


module "cloudtrail" {
  source = "./modules/cloudtrail"

  trail_bucket_name          = var.cloudtrail_bucket_name
  multi_region               = var.cloudtrail_multi_region
  enable_log_file_validation = var.cloudtrail_enable_log_file_validation
  ec2_termination_alert_email = var.ec2_termination_alert_email
}


