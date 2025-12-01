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

######################################
# Common Data Sources
######################################

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

######################################
# VPC Data Sources
######################################

data "aws_vpc" "existing" {
  count = var.use_existing_vpc ? 1 : 0
  id    = var.existing_vpc_id
}

data "aws_subnets" "existing_private" {
  count = var.use_existing_vpc && length(var.existing_private_subnet_ids) == 0 ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [var.existing_vpc_id]
  }
}

data "aws_subnet" "existing_private_details" {
  count = var.use_existing_vpc ? length(var.existing_private_subnet_ids) : 0
  id    = var.existing_private_subnet_ids[count.index]
}

data "aws_security_group" "existing" {
  count  = var.use_existing_vpc && var.existing_security_group_id != "" ? 1 : 0
  id     = var.existing_security_group_id
  vpc_id = var.existing_vpc_id
}

######################################
# IAM Data Sources
######################################

data "aws_iam_policy" "AmazonSageMakerFullAccess" {
  name = "AmazonSageMakerFullAccess"
}

data "aws_iam_policy" "AmazonSageMakerCanvasFullAccess" {
  count = var.canvas_use ? 1 : 0
  name  = "AmazonSageMakerCanvasFullAccess"
}

data "aws_iam_policy" "AmazonSageMakerCanvasAIServicesAccess" {
  count = var.canvas_use ? 1 : 0
  name  = "AmazonSageMakerCanvasAIServicesAccess"
}

data "aws_iam_policy_document" "sagemaker_domain_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com", "forecast.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "data_scientist" {
  name = "DataScientist"
}

data "aws_iam_policy" "ml_engineer" {
  name = "PowerUserAccess"
}

######################################
# Locals
######################################

locals {
  common_tags = {
    Environment = var.environment
    Application = var.application
  }

  ### VPC ###
  vpc_name = "${var.domain_name}-${var.environment}-vpc"

  # VPC references from vpc.tf
  vpc_id = var.use_existing_vpc ? var.existing_vpc_id : module.vpc[0].vpc_id

  # Determine private subnet IDs with validation
  discovered_subnet_ids = var.use_existing_vpc && length(var.existing_private_subnet_ids) == 0 ? (
    try(data.aws_subnets.existing_private[0].ids, [])
  ) : []

  private_subnet_ids = var.use_existing_vpc ? (
    length(var.existing_private_subnet_ids) > 0 ? var.existing_private_subnet_ids : local.discovered_subnet_ids
  ) : module.vpc[0].private_subnets

  security_group_id = var.use_existing_vpc ? (
    var.existing_security_group_id != "" ? var.existing_security_group_id : aws_security_group.sagemaker_existing_vpc[0].id
  ) : module.vpc[0].default_security_group_id

  vpc_cidr = var.use_existing_vpc ? data.aws_vpc.existing[0].cidr_block : var.cidr_block

  # Validation flag
  has_valid_subnets = length(local.private_subnet_ids) > 0

  # Fail fast if existing VPC has no usable private subnets
  _validate_existing_vpc_subnets = var.use_existing_vpc && !local.has_valid_subnets ? error(
    "When use_existing_vpc is true, you must provide non-empty private subnets via existing_private_subnet_ids or ensure they are discoverable via data.aws_subnets.existing_private."
  ) : true

  ### SageMaker Domain ###
  sagemaker = {
    jupyter_image_tag = var.jupyter_image_tag
    image_arn_prefix  = var.sagemaker_image_arn_prefix
  }

  sagemaker_image_arn = "${local.sagemaker.image_arn_prefix}/${local.sagemaker.jupyter_image_tag}"

  ### SageMaker Spaces ###  
  private_user_spaces_list = flatten([for user_key, user in var.sm_settings : [for space_key, space in user.spaces : merge(space, {
    space_key    = "${user_key}_${space_key}"
    name         = space_key
    sharing_type = "Private"
    owner        = user_key
  })]])

  private_spaces = { for private_user_spaces in local.private_user_spaces_list : private_user_spaces.space_key => private_user_spaces }

  shared_spaces_list = flatten([for user_key, user in var.shared_spaces : [for space_key, space in user.spaces : merge(space, {
    space_key    = "${user_key}_${space_key}"
    name         = space_key
    sharing_type = "Shared"
    owner        = user_key
  })]])

  shared_spaces = { for shared_user_spaces in local.shared_spaces_list : shared_user_spaces.space_key => shared_user_spaces }

  spaces = merge(local.private_spaces, local.shared_spaces)

  ### User Profile Roles ###
  data_scientists = { for user_key, user in var.sm_settings : user_key => user if user.role == "DataScientist" }
  ml_engineer     = { for user_key, user in var.sm_settings : user_key => user if user.role == "MLEngineer" }
}