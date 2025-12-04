data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "trail" {
  bucket = var.trail_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.trail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "trail" {
  bucket = aws_s3_bucket.trail.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "name" {
    bucket = aws_s3_bucket.trail.id
    
    rule {
        object_ownership = "BucketOwnerEnforced"
    }
}   

data "aws_iam_policy_document" "cloudtrail_put" {
  statement {
    sid = "AllowCloudTrailWrite"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      aws_s3_bucket.trail.arn
    ]
  }

  statement {
    sid = "AllowCloudTrailWriteObjects"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.trail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid = "AllowConfigBucketAccess"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.trail.arn
    ]
  }

  statement {
    sid = "AllowConfigWriteObjects"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.trail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}


resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.trail.id
  policy = data.aws_iam_policy_document.cloudtrail_put.json
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/account"
  retention_in_days = 90
}

resource "aws_iam_role" "cloudtrail_logs" {
  name = "cloudtrail-cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudtrail_logs" {
  name = "cloudtrail-cloudwatch-logs-policy"
  role = aws_iam_role.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_cloudtrail" "trail" {
  name                          = "trail"
  s3_bucket_name                = aws_s3_bucket.trail.bucket
  include_global_service_events = true
  is_multi_region_trail         = var.multi_region
  enable_log_file_validation    = true
  enable_logging                = true

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_logs.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  depends_on = [
    aws_s3_bucket_policy.cloudtrail,
    aws_iam_role_policy.cloudtrail_logs
  ]
}


resource "aws_iam_role" "config_role" {
  name = "aws-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# resource "aws_iam_role_policy_attachment" "config_managed_policy" {
#   role       = aws_iam_role.config_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
# }

resource "aws_iam_role_policy" "config_policy" {
  role = aws_iam_role.config_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.trail.id}",
          "arn:aws:s3:::${aws_s3_bucket.trail.id}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "config:Put*",
          "config:Get*",
          "config:Describe*",
          "config:List*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_config_configuration_recorder" "config" {
  name     = "default"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "config_delivery" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.trail.bucket

  depends_on = [
    aws_s3_bucket_policy.cloudtrail
  ]
}

resource "aws_config_configuration_recorder_status" "config_status" {
  name       = aws_config_configuration_recorder.config.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.config_delivery
  ]
}

resource "aws_config_config_rule" "s3_encryption" {
  name = "s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [
    aws_config_configuration_recorder_status.config_status
  ]
}

resource "aws_config_config_rule" "cloudtrail_enabled" {
  name = "cloudtrail-enabled"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"
  }

  depends_on = [
    aws_config_configuration_recorder_status.config_status
  ]
}

resource "aws_cloudwatch_log_metric_filter" "ec2_terminate_instances" {
  name           = "EC2TerminateInstances"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  pattern = "{ ($.eventName = \"TerminateInstances\") && ($.eventSource = \"ec2.amazonaws.com\") }"

  metric_transformation {
    name      = "EC2TerminateInstancesCount"
    namespace = "Security/CloudTrail"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_terminate_instances_alarm" {
  alarm_name        = "EC2TerminateInstancesAlarm"
  alarm_description = "Triggers whenever an EC2 instance is terminated (TerminateInstances API call)."

  namespace           = "Security/CloudTrail"
  metric_name         = "EC2TerminateInstancesCount"
  statistic           = "Sum"
  period              = 300   
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  alarm_actions = [
    aws_sns_topic.ec2_terminate_instances_topic.arn
  ]

  depends_on = [
    aws_cloudwatch_log_metric_filter.ec2_terminate_instances
  ]
}

resource "aws_sns_topic" "ec2_terminate_instances_topic" {
  name = "ec2-terminate-instances-topic"
}

resource "aws_sns_topic_subscription" "ec2_terminate_instances_email" {
  topic_arn = aws_sns_topic.ec2_terminate_instances_topic.arn
  protocol  = "email"
  endpoint  = var.ec2_termination_alert_email
}
