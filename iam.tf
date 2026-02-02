######################################
# IAM Policies and Roles
######################################

resource "aws_iam_policy" "ec2_execution_policy" {
  name = "SMAdditionalExecutionPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowEC2Actions"
        Action = [
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:DescribeNetworkInterfaceAttribute",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeImages",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupEgress"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "app_management" {
  name = "SMAppsManagement"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SMStudioUserProfileAppPermissionsCreateAndDelete"
        Effect = "Allow"
        Action = [
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp",
          "sagemaker:UpdateApp"
        ]
        Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:app/*"
        Condition = {
          Null = {
            "sagemaker:OwnerUserProfileArn" = "true"
          }
        }
      },
      {
        Sid      = "SMStudioCreatePresignedDomainUrlForUserProfile"
        Effect   = "Allow"
        Action   = ["sagemaker:CreatePresignedDomainUrl"]
        Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:user-profile/$${sagemaker:DomainId}/$${sagemaker:UserProfileName}"
      },
      {
        Sid      = "SMStudioAppPermissionsTagOnCreate"
        Effect   = "Allow"
        Action   = ["sagemaker:AddTags"]
        Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/*"
        Condition = {
          Null = {
            "sagemaker:TaggingAction" = "false"
          }
        }
      },
      {
        Sid    = "SMStudioRestrictCreatePrivateSpaceAppsToOwnerUserProfile"
        Effect = "Allow"
        Action = [
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp"
        ]
        Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:app/$${sagemaker:DomainId}/*"
        Condition = {
          ArnLike = {
            "sagemaker:OwnerUserProfileArn" = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:user-profile/$${sagemaker:DomainId}/$${sagemaker:UserProfileName}"
          }
          StringEquals = {
            "sagemaker:SpaceSharingType" = ["Private"]
          }
        }
      },
      {
        Sid    = "AllowAppActionsForSharedSpaces"
        Effect = "Allow"
        Action = [
          "sagemaker:CreateApp",
          "sagemaker:DeleteApp"
        ]
        Resource = "arn:aws:sagemaker:*:*:app/$${sagemaker:DomainId}/*/*/*"
        Condition = {
          StringEquals = {
            "sagemaker:SpaceSharingType" = ["Shared"]
          }
        }
      },
      {
        Sid    = "AllowMLflowAppActions"
        Effect = "Allow"
        Action = [
          "sagemaker-mlflow:*"
        ]
        Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:mlflow-app/*"
      }
    ]
  })
}

resource "aws_iam_policy" "space_management" {
  name = "SMSpacesManagement"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SMStudioRestrictSharedSpacesWithoutOwners"
        Effect = "Allow"
        Action = [
          "sagemaker:CreateSpace",
          "sagemaker:UpdateSpace",
          "sagemaker:DeleteSpace"
        ]
        Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:space/$${sagemaker:DomainId}/*"
        Condition = {
          Null = {
            "sagemaker:OwnerUserProfileArn" = "true"
          }
        }
      },
      {
        Sid    = "SMStudioRestrictSpacesToOwnerUserProfile"
        Effect = "Allow"
        Action = [
          "sagemaker:CreateSpace",
          "sagemaker:UpdateSpace",
          "sagemaker:DeleteSpace"
        ]
        Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:space/$${sagemaker:DomainId}/*"
        Condition = {
          ArnLike = {
            "sagemaker:OwnerUserProfileArn" = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:user-profile/$${sagemaker:DomainId}/$${sagemaker:UserProfileName}"
          }
          StringEquals = {
            "sagemaker:SpaceSharingType" = [
              "Private",
              "Shared"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "additional_sm_permissions" {
  name = "SMAdditionalPermissions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sagemaker:UpdateDomain",
          "sagemaker:CreateDomain",
          "sagemaker:CreateUserProfile",
          "sagemaker:UpdateSpace",
          "sagemaker:DeleteUserProfile",
          "sagemaker:DeleteDomain"
        ]
        Resource = "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*/*"
        Condition = {
          Null = {
            "sagemaker:OwnerUserProfileArn" = "true"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutBucketCORS"
        ]
        Resource = "arn:aws:s3:::*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole",
          "iam:PassRole"
        ]
        Resource = "arn:aws:iam::*:role/*AmazonSageMaker*"
      }
    ]
  })
}


####################################
# SageMaker Domain Execution Role
####################################

resource "aws_iam_role" "sagemaker_domain_execution_role" {
  name               = var.sagemaker_domain_execution_role
  assume_role_policy = data.aws_iam_policy_document.sagemaker_domain_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ec2_execution_policy" {
  role       = aws_iam_role.sagemaker_domain_execution_role.name
  policy_arn = aws_iam_policy.ec2_execution_policy.arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_full_access" {
  role       = aws_iam_role.sagemaker_domain_execution_role.name
  policy_arn = data.aws_iam_policy.AmazonSageMakerFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_canvas_full_access" {
  count      = var.canvas_use ? 1 : 0
  role       = aws_iam_role.sagemaker_domain_execution_role.name
  policy_arn = data.aws_iam_policy.AmazonSageMakerCanvasFullAccess[0].arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_canvas_ai_services" {
  count      = var.canvas_use ? 1 : 0
  role       = aws_iam_role.sagemaker_domain_execution_role.name
  policy_arn = data.aws_iam_policy.AmazonSageMakerCanvasAIServicesAccess[0].arn
}

resource "aws_iam_role_policy_attachment" "apps_management" {
  role       = aws_iam_role.sagemaker_domain_execution_role.name
  policy_arn = aws_iam_policy.app_management.arn
}

resource "aws_iam_role_policy_attachment" "spaces_management" {
  role       = aws_iam_role.sagemaker_domain_execution_role.name
  policy_arn = aws_iam_policy.space_management.arn
}

resource "aws_iam_role_policy_attachment" "additional_sm_permissions" {
  role       = aws_iam_role.sagemaker_domain_execution_role.name
  policy_arn = aws_iam_policy.additional_sm_permissions.arn
}

######################################
# Data Scientist Role
######################################

resource "aws_iam_role" "data_scientist" {
  name = "${var.application}-DataScientist"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
        Effect = "Allow"
      },
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })

  tags = {
    "Role" = "DataScientist"
  }
}

resource "aws_iam_role_policy_attachment" "data_scientist_role" {
  role       = aws_iam_role.data_scientist.name
  policy_arn = data.aws_iam_policy.data_scientist.arn
}

resource "aws_iam_role_policy_attachment" "ds_app_management" {
  role       = aws_iam_role.data_scientist.name
  policy_arn = aws_iam_policy.app_management.arn
}

######################################
# EMR Full Access Policy
######################################

resource "aws_iam_policy" "eneable_emr_capabilities_policy" {
  count = var.eneable_emr_capabilities_policy ? 1 : 0
  name  = "EMRAdminPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # EMR Cluster permissions
      {
        Sid    = "AllowEMRReadAccess"
        Effect = "Allow"
        Action = [
          "elasticmapreduce:ListClusters",
          "elasticmapreduce:DescribeCluster",
          "elasticmapreduce:ListInstances",
          "elasticmapreduce:ListInstanceGroups",
          "elasticmapreduce:ListBootstrapActions",
          "elasticmapreduce:DescribeStep",
          "elasticmapreduce:ListSteps",
          "elasticmapreduce:GetManagedScalingPolicy"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowEMRManagement"
        Effect = "Allow"
        Action = [
          "elasticmapreduce:AddJobFlowSteps",
          "elasticmapreduce:CancelSteps",
          "elasticmapreduce:TerminateJobFlows",
          "elasticmapreduce:RunJobFlow",
          "elasticmapreduce:SetTerminationProtection",
          "elasticmapreduce:ModifyCluster",
          "elasticmapreduce:AddTags",
          "elasticmapreduce:RemoveTags"
        ]
        Resource = "arn:aws:elasticmapreduce:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/*"
      },
      # EMR Serverless permissions - List applications
      {
        Sid    = "EMRServerlessListApplications"
        Effect = "Allow"
        Action = [
          "emr-serverless:ListApplications"
        ]
        Resource = "arn:aws:emr-serverless:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:/*"
      },
      # EMR Serverless - Create and Tag with SageMaker tags
      {
        Sid    = "EMRServerlessCreateApplicationAction"
        Effect = "Allow"
        Action = [
          "emr-serverless:CreateApplication",
          "emr-serverless:TagResource"
        ]
        Resource = "arn:aws:emr-serverless:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:/*"
        Condition = {
          ForAllValues = {
            StringEquals = {
              "aws:TagKeys" = [
                "sagemaker:domain-arn",
                "sagemaker:user-profile-arn",
                "sagemaker:space-arn"
              ]
            }
          }
          Null = {
            "aws:RequestTag/sagemaker:domain-arn"       = "false"
            "aws:RequestTag/sagemaker:user-profile-arn" = "false"
            "aws:RequestTag/sagemaker:space-arn"        = "false"
          }
        }
      },
      # Deny tagging actions on untagged resources
      {
        Sid    = "EMRServerlessDenyTaggingAction"
        Effect = "Deny"
        Action = [
          "emr-serverless:TagResource",
          "emr-serverless:UntagResource"
        ]
        Resource = "arn:aws:emr-serverless:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:/*"
        Condition = {
          Null = {
            "aws:ResourceTag/sagemaker:domain-arn"       = "true"
            "aws:ResourceTag/sagemaker:user-profile-arn" = "true"
            "aws:ResourceTag/sagemaker:space-arn"        = "true"
          }
        }
      },
      # EMR Serverless - Manage tagged applications
      {
        Sid    = "EMRServerlessActions"
        Effect = "Allow"
        Action = [
          "emr-serverless:StartApplication",
          "emr-serverless:StopApplication",
          "emr-serverless:GetApplication",
          "emr-serverless:DeleteApplication",
          "emr-serverless:AccessLivyEndpoints",
          "emr-serverless:GetDashboardForJobRun"
        ]
        Resource = "arn:aws:emr-serverless:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:/applications/*"
        Condition = {
          Null = {
            "aws:ResourceTag/sagemaker:domain-arn"       = "false"
            "aws:ResourceTag/sagemaker:user-profile-arn" = "false"
            "aws:ResourceTag/sagemaker:space-arn"        = "false"
          }
        }
      },
      # IAM permissions for Studio UI
      {
        Sid    = "AllowListRolesForStudioUI"
        Effect = "Allow"
        Action = [
          "iam:ListRoles"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowPassRoleForEMR"
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          aws_iam_role.emr_serverless_s3_runtime[0].arn
        ]
        Condition = {
          StringLike = {
            "iam:PassedToService" = [
              "elasticmapreduce.amazonaws.com",
              "emr-serverless.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ds_eneable_emr_capabilities_policy" {
  count      = var.eneable_emr_capabilities_policy ? 1 : 0
  role       = aws_iam_role.data_scientist.name
  policy_arn = aws_iam_policy.eneable_emr_capabilities_policy[0].arn
}

######################################
# ML Engineer Role
######################################

resource "aws_iam_role" "ml_engineer" {
  name = "${var.application}-MLEngineer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })

  tags = {
    "Role" = "MLEngineer"
  }
}

resource "aws_iam_role_policy_attachment" "ml_engineer_role" {
  role       = aws_iam_role.ml_engineer.name
  policy_arn = data.aws_iam_policy.ml_engineer.arn
}

######################################
# KMS Policy
######################################

resource "aws_iam_policy" "sagemaker_kms" {
  count       = var.kms_encryption ? 1 : 0
  name        = "sagemaker_kms_policy"
  path        = "/"
  description = "KMS policy for SageMaker"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:CreateGrant"
        ]
        Effect = "Allow"
        Resource = [
          var.kms_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_kms" {
  count      = var.kms_encryption ? 1 : 0
  role       = aws_iam_role.sagemaker_domain_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_kms[0].arn
}

######################################
# EMR Serverless S3 Runtime Role
######################################

resource "aws_iam_role" "emr_serverless_s3_runtime" {
  count = var.emr_s3_bucket_name != "" ? 1 : 0
  name  = "EMRServerlessS3RuntimeRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "emr-serverless.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy" "emr_serverless_s3_access" {
  count = var.emr_s3_bucket_name != "" ? 1 : 0
  name  = "EMRServerlessS3Access"
  role  = aws_iam_role.emr_serverless_s3_runtime[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = "arn:aws:s3:::${var.emr_s3_bucket_name}"
      },
      {
        Sid    = "ObjectOperations"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:PutObjectAcl",
          "s3:PutObjectVersionAcl",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = "arn:aws:s3:::${var.emr_s3_bucket_name}/*"
      }
    ]
  })
}
