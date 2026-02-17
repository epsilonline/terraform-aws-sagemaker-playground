######################################
# SageMaker Domain
######################################

resource "aws_sagemaker_domain" "sagemaker_domain" {
  domain_name = var.domain_name
  auth_mode   = var.auth_mode
  vpc_id      = local.vpc_id
  subnet_ids  = [local.private_subnet_ids[0]]

  default_space_settings {
    execution_role  = aws_iam_role.sagemaker_domain_execution_role.arn
    security_groups = [local.security_group_id]
  }

  default_user_settings {
    execution_role = aws_iam_role.sagemaker_domain_execution_role.arn
    jupyter_server_app_settings {
      default_resource_spec {
        instance_type       = var.instance_type
        sagemaker_image_arn = local.sagemaker_image_arn
      }
    }

    dynamic "jupyter_lab_app_settings" {
      for_each = var.default_idle_timeout_in_minutes != null ? [1] : []
      content {
        app_lifecycle_management {
          idle_settings {
            lifecycle_management        = "ENABLED"
            idle_timeout_in_minutes     = var.default_idle_timeout_in_minutes
            max_idle_timeout_in_minutes = var.default_idle_timeout_in_minutes
            min_idle_timeout_in_minutes = var.default_idle_timeout_in_minutes
          }
        }
      }
    }

    dynamic "code_editor_app_settings" {
      for_each = var.default_idle_timeout_in_minutes != null ? [1] : []
      content {
        app_lifecycle_management {
          idle_settings {
            lifecycle_management        = "ENABLED"
            idle_timeout_in_minutes     = var.default_idle_timeout_in_minutes
            max_idle_timeout_in_minutes = var.default_idle_timeout_in_minutes
            min_idle_timeout_in_minutes = var.default_idle_timeout_in_minutes
          }
        }
      }
    }

    canvas_app_settings {
      time_series_forecasting_settings {
        status = "ENABLED"
      }
    }
  }

  domain_settings {
    docker_settings {
      enable_docker_access = var.enable_docker
    }
    security_group_ids = [local.security_group_id]
  }

  kms_key_id = try(aws_kms_key.sagemaker_efs_kms_key[0].arn, null)

  app_network_access_type = var.app_network_access_type

  retention_policy {
    home_efs_file_system = var.efs_retention_policy
  }

  depends_on = [
    aws_security_group.sagemaker_existing_vpc,
    aws_security_group_rule.allow_outbound_traffic,
    aws_security_group_rule.allow_jupyter_inbound_traffic,
    aws_security_group_rule.allow_git_inbound_traffic
  ]

  lifecycle {
    precondition {
      condition     = local.has_valid_subnets
      error_message = "No private subnets available. Please provide existing_private_subnet_ids or ensure subnets exist in the VPC."
    }
  }
}

######################################
# SageMaker User Profiles
######################################

resource "aws_sagemaker_user_profile" "data_scientist" {
  for_each          = local.data_scientists
  domain_id         = aws_sagemaker_domain.sagemaker_domain.id
  user_profile_name = each.key

  user_settings {
    execution_role  = aws_iam_role.data_scientist.arn
    security_groups = [local.security_group_id]

    jupyter_lab_app_settings {
      dynamic "app_lifecycle_management" {
        for_each = var.default_idle_timeout_in_minutes != null ? [1] : []
        content {
          idle_settings {
            lifecycle_management        = "ENABLED"
            idle_timeout_in_minutes     = var.default_idle_timeout_in_minutes
            max_idle_timeout_in_minutes = var.default_idle_timeout_in_minutes
            min_idle_timeout_in_minutes = var.default_idle_timeout_in_minutes
          }
        }
      }

      dynamic "emr_settings" {
        for_each = var.emr_s3_bucket_name != "" ? [1] : []
        content {
          execution_role_arns = [aws_iam_role.emr_serverless_s3_runtime[0].arn]
        }
      }
    }
  }
}

resource "aws_sagemaker_user_profile" "ml_engineer" {
  for_each          = local.ml_engineer
  domain_id         = aws_sagemaker_domain.sagemaker_domain.id
  user_profile_name = each.key

  user_settings {
    execution_role  = aws_iam_role.ml_engineer.arn
    security_groups = [local.security_group_id]
  }
}

######################################
# Sagemaker Spaces
######################################

resource "aws_sagemaker_space" "sagemaker_space" {
  for_each   = local.spaces
  domain_id  = aws_sagemaker_domain.sagemaker_domain.id
  space_name = each.value.name

  space_sharing_settings {
    sharing_type = each.value.sharing_type
  }

  ownership_settings {
    owner_user_profile_name = try(each.value.owner, null)
  }

  space_settings {
    app_type = each.value.app_type
    
    dynamic "jupyter_lab_app_settings" {
      for_each = each.value.app_type == "JupyterLab" ? [1] : []
      content {
        dynamic "app_lifecycle_management" {
          for_each = each.value.idle_timeout_in_minutes != null ? [1] : []
          content {
            idle_settings {
              idle_timeout_in_minutes = each.value.idle_timeout_in_minutes
            }
          }
        }
        default_resource_spec {
          instance_type = each.value.instance_type
        }
      }
    }

    dynamic "code_editor_app_settings" {
      for_each = each.value.app_type == "CodeEditor" ? [1] : []
      content {
        dynamic "app_lifecycle_management" {
          for_each = each.value.idle_timeout_in_minutes != null ? [1] : []
          content {
            idle_settings {
              idle_timeout_in_minutes = each.value.idle_timeout_in_minutes
            }
          }
        }
        default_resource_spec {
          instance_type = each.value.instance_type
        }
      }
    }
  }

  depends_on = [
    aws_sagemaker_user_profile.data_scientist,
    aws_sagemaker_user_profile.ml_engineer
  ]

}

resource "aws_sagemaker_app" "sm_app" {
  for_each = local.spaces

  domain_id  = aws_sagemaker_domain.sagemaker_domain.id
  space_name = each.value.name
  app_name   = each.value.app_name
  app_type   = each.value.app_type
  resource_spec {
    instance_type       = each.value.instance_type
    sagemaker_image_arn = each.value.image_arn
  }

  depends_on = [aws_sagemaker_space.sagemaker_space]
  lifecycle {
    ignore_changes = [
      # Ignores changes caused by app getting stopped from console
      resource_spec[0].sagemaker_image_arn,
      resource_spec[0].sagemaker_image_version_alias
    ]
  }
}

######################################
# KMS Key
######################################


resource "aws_kms_key" "sagemaker_efs_kms_key" {
  count               = var.kms_encryption ? 1 : 0
  description         = "KMS key to encrypt SageMaker EFS volume"
  enable_key_rotation = true
}

resource "aws_kms_key_policy" "efs_kms_policy" {
  count  = var.kms_encryption ? 1 : 0
  key_id = aws_kms_key.sagemaker_efs_kms_key[0].id
  policy = jsonencode({
    Id = ""
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }

        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
    ]
    Version = "2012-10-17"
  })
}