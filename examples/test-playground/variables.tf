######################################
# Shared vars
######################################

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "eu-west-1"
}

variable "environment" {
  type = string
  description = "Application environment"

}

variable "application" {
  type = string
  description = "Application name"
}

######################################
# SageMaker
######################################

variable "domain_name" {
  type        = string
  description = "Sagemaker Domain Name"
  default     = ""
}

variable "auth_mode" {
  type        = string
  description = "Authentication mode to access the domain"
  default     = ""
}

variable "instance_type" {
 type = string 
}

variable "sagemaker_domain_execution_role" {
 type = string
 description = "value" 
}

variable "app_network_access_type" {
  type        = string
  description = "VPC used for non-EFS traffic"
  default     = ""
}

variable "efs_retention_policy" {
  type        = string
  description = "Retention policy for data on an EFS volume"
  default     = ""
}

variable "enable_docker" {
  type = string
  description = "Enables Local Mode and Docker Access"
}

variable "canvas_use" {
  type = bool
  description = "Enables the creation of resources for SageMaker Canvas"
}

variable "jupyter_image_tag" {
  type = string
  description = "Jupyter Image Tag"
}

variable "sagemaker_image_arn_prefix" {  
  type = string
  description = "SageMaker Image Arn prefix"
}

######################################
# SageMaker Profiles
######################################

variable "sm_settings" {
  description = "SageMaker profiles and Private Spaces to create for the domain"
  type = map(object({
    role = string
    spaces = map(object({
      app_type                = string
      app_name                = string
      instance_type           = string
      image_arn               = string
      idle_timeout_in_minutes = optional(number)
    }))

  }))
}

######################################
# SageMaker Shared Spaces
######################################

variable "shared_spaces" {
  description = "Shared Spaces to create for the domain"
  type = map(object({
    spaces = map(object({
      app_type                = string
      app_name                = string
      instance_type           = string
      image_arn               = string
      idle_timeout_in_minutes = optional(number)
    }))

  }))
}

######################################
# KMS
######################################

variable "kms_encryption" {
  type = bool
  description = "Enables the creation of encryption resources"
}


variable "kms_arn" {
  type        = string
  description = "KMS key EFS encryption"
  default = ""
}

######################################
# VPC
######################################

variable "cidr_block" {
  type        = string
  description = "CIDR block for SageMaker VPC"
  default = ""
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default = [ "" ]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default = [ "" ]
  }

variable "enable_dns_support" {
  type = bool
  description = "Enables DNS Support"
}

variable "enable_dns_hostnames" {
  type = bool
  description = "Enables DNS Hostnames"
}

variable "enable_nat_gateway" {
 type = bool
 description = "Enables creation of Nat Gateway"
}

variable "single_nat_gateway" {
type = bool
description = "Creates a single one NGW"
}

variable "one_ngw_per_az" {
type = bool
description = "Creates only one NGW per AZ"
}

variable "enable_vpn_gateway" {
 type = bool
 description = "Enables creation of VPN Gateway"

}