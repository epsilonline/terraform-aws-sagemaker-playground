provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">=1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.2"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "sagemaker_playground" {
  source = "epsilonline/sagemaker-playground/aws"
  version = "~>1.0.0"

  #Shared Vars
  aws_region              = var.aws_region
  application = var.application
  environment = var.environment
  #SageMaker Domain
  domain_name             = var.domain_name
  auth_mode               = var.auth_mode
  instance_type = var.instance_type
  sagemaker_domain_execution_role = var.sagemaker_domain_execution_role
  app_network_access_type = var.app_network_access_type
  efs_retention_policy    = var.efs_retention_policy
  enable_docker = var.enable_docker
  canvas_use = var.canvas_use
  jupyter_image_tag = var.jupyter_image_tag
  sagemaker_image_arn_prefix = var.sagemaker_image_arn_prefix
  #SageMaker Profiles and Spaces
  sm_settings = var.sm_settings
  shared_spaces = var.shared_spaces
  #KMS
  kms_encryption          = var.kms_encryption
  kms_arn                 = var.kms_arn
  #VPC
  cidr_block              = var.cidr_block
  private_subnet_cidrs    = var.private_subnet_cidrs
  public_subnet_cidrs     = var.public_subnet_cidrs
  azs                     = var.azs
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  one_ngw_per_az        = var.one_ngw_per_az
  enable_vpn_gateway = var.enable_vpn_gateway
}