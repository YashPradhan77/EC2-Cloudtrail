resource "aws_instance" "web" {
    ami           = var.ec2_ami
    instance_type = var.ec2_instance_type
    subnet_id     = var.ec2_subnet_id[0]
    vpc_security_group_ids = var.ec2_security_groups
    associate_public_ip_address = var.associate_public_ip
    iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
    
    root_block_device {
      volume_size = var.volume_size
      volume_type = var.volume_type
      encrypted   = var.encrypted
      kms_key_id  = aws_kms_key.ebs.arn
    }

    user_data = file("${path.module}/script.sh")
}

resource "aws_iam_policy" "ec2_kms_policy" {
  name        = "kms-access"
  description = "Allow EC2 instances to use the EBS KMS key"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowUseOfKMSKey"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*"
        ]
        Resource = aws_kms_key.ebs.arn
      }
    ]
  })
}


resource "aws_iam_role" "ec2_role" {
  name               = "ec2-kms-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

}

data "aws_iam_policy_document" "ec2_secrets_access" {
  statement {
    sid    = "AllowReadSpecificSecret"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [
      aws_secretsmanager_secret.app_db_credentials.arn
    ]
  }
}

resource "aws_iam_policy" "ec2_secrets_access" {
  name   = "ec2-app-db-secrets-access"
  policy = data.aws_iam_policy_document.ec2_secrets_access.json
}

resource "aws_iam_role_policy_attachment" "attach_ec2_kms" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_kms_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_secrets_access_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_secrets_access.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  role = aws_iam_role.ec2_role.name
}