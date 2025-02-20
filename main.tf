provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

terraform {
  required_version = ">=1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.82.2"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  common_tags = {
      Environment = var.environment
      Application = var.application
  }
  
### VPC ###
  vpc_name = "${var.domain_name}-${var.environment}-vpc"

### SageMaker Domain ###
  sagemaker = {
    jupyter_image_tag = var.jupyter_image_tag
    image_arn_prefix  = var.sagemaker_image_arn_prefix
  }
  
  sagemaker_image_arn = "${local.sagemaker.image_arn_prefix}/${local.sagemaker.jupyter_image_tag}"

### SageMaker Spaces ###  
  private_user_spaces_list = flatten([for user_key,user in var.sm_settings : [ for space_key,space in user.spaces : merge(space,{
    space_key    = "${user_key}_${space_key}"
    name         = space_key
    sharing_type = "Private"
    owner        = user_key
  })]])

  private_spaces = { for private_user_spaces in local.private_user_spaces_list : private_user_spaces.space_key =>  private_user_spaces}

  shared_spaces_list = flatten([for user_key,user in var.shared_spaces : [ for space_key,space in user.spaces : merge(space, {
    space_key    = "${user_key}_${space_key}"
    name         = space_key
    sharing_type = "Shared"
    owner        = user_key
    })]])

  shared_spaces = { for shared_user_spaces in local.shared_spaces_list : shared_user_spaces.space_key =>  shared_user_spaces}

  spaces = merge(local.private_spaces, local.shared_spaces)

### User Profile Roles ###
  data_scientists = {for user_key, user in var.sm_settings : user_key => user if user.role == "DataScientist"} 
  ml_engineer = {for user_key, user in var.sm_settings : user_key => user if user.role == "MLEngineer"} 
}