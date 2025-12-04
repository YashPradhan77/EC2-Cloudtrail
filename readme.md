# Deployment Overview

This repository provisions opinionated, production-ready networking and compute infrastructure via Terraform using a modular, environment-driven layout.

Core components deployed

* Creates a VPC with public and private subnets (multi-AZ capable via variables).
* Deploys an EC2 instance into a **private subnet** .
* Creates Security Groups with least-privilege rules.
* Creates IAM roles with least-privilege for the EC2 instance and CloudTrail delivery.
* Enables CloudTrail and sends logs to an encrypted S3 bucket and to CloudWatch Logs.
* Enables EBS encryption by default and S3 default encryption.
* Enables VPC Flow Logs to CloudWatch.
* Implements AWS Config with managed rules to enforce security posture.
* Adds a CloudWatch alarm triggered when CloudTrail surfaces `UnauthorizedOperation` events.
* Stores an example secret in Secrets Manager.

Modules present in this workspace

* `modules/CloudTrail` — CloudTrail configuration , S3/CloudWatch integration and AWS Config 
* `modules/EC2` — EC2, ALB, and EBS resources
* `modules/SG` — Security Group definitions and outputs
* `root/` - root Terraform files that call modules
---

## Prerequisites

* Terraform >= 1.6  
* AWS CLI configured with credentials that can create networking, IAM, logging, and compute resources
* (Recommended) An S3 bucket + DynamoDB table for the remote Terraform backend to enable team collaboration
* Review `variable.tf` and module `variables.tf` files for configurable values

> Important: Do not commit `terraform.tfstate` or any files that contain secrets. Use a remote backend for team workflows.

---

## Deployment

1. Initialize Terraform and the backend

```bash
terraform init
```

If you use an S3 backend with custom settings, pass backend configuration via `-backend-config` or set it in `backend.tf`.

2. Validate the configuration

```bash
terraform validate
```

3. Plan and apply (examples)

```bash
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

For CI or non-interactive runs, add `-auto-approve`.

If you use workspaces to separate environments run `terraform workspace select <env>` or `terraform workspace new <env>` first.

---

## Security and Observability Best Practices

This project enforces conservative defaults to improve security and operational clarity:

* Least-privilege network design — private subnets have no direct ingress from the internet; outbound traffic from private subnets flows through NAT Gateway(s).
* Security groups are narrow — only essential ports are allowed; avoid 0.0.0.0/0 unless explicitly required and justified.
* IAM hardening — scoped roles and policies (CloudTrail and Flow Logs use dedicated roles with minimal permissions).
* Logging and retention — VPC Flow Logs are delivered to CloudWatch; log groups have explicit retention to avoid uncontrolled storage costs.
* Explicit resource naming and tagging to support multi-environment deployments and auditing.

---

## Design Choices (rationale)

* VPC Flow Logs → CloudWatch: prioritizes real-time troubleshooting and integration with CloudWatch Insights. Use S3 for long-term/archival retention only when required by compliance.
* NAT Gateway for private subnet egress: prioritizes operational simplicity and predictable behavior despite cost.
* Multi-AZ subnets for high availability; avoid single-AZ designs for production workloads.
* Flow Logs are implemented as a standalone module (decoupled from the VPC) to reduce coupling and blast radius during updates.

<img width="885" height="106" alt="Screenshot 2025-11-20 at 14 34 27" src="https://github.com/user-attachments/assets/104c5914-981b-4c16-bafc-ef0edfd1d843" />

---

## Files of interest

* `provider.tf`, `backend.tf` — provider and backend setup
* `variable.tf` — top-level variables
* `modules/` — reusable components (CloudTrail, EC2, SG)
* `terraform.tfvars` — environment values used for plan/apply

---

## Notes & housekeeping

* Ensure any S3 backend bucket and DynamoDB table used for state locking are created before `terraform init` if not managed by Terraform.
* Never check in `terraform.tfstate` or sensitive variable files into version control.
* The workspace includes `terraform.tfstate` locally for convenience; switch to a remote backend for team collaboration.

---
