######################################
# Shared vars
######################################

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = ""
}

variable "environment" {
  type        = string
  description = "Application environment"
}

variable "application" {
  type        = string
  description = "Application name"
}

######################################
# SageMaker Domain
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
  type        = string
  description = "Execution role for SageMaker Domain"
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
  type        = string
  default     = "DISABLED"
  description = "Enables Local Mode and Docker Access"
}

variable "canvas_use" {
  type        = bool
  description = "Enables the creation of resources for SageMaker Canvas"
}

variable "jupyter_image_tag" {
  type        = string
  description = "Jupyter Image Tag"
}

variable "sagemaker_image_arn_prefix" {
  type        = string
  description = "SageMaker Image Arn prefix"
}

variable "default_idle_timeout_in_minutes" {
  type        = number
  description = "Idle timeout in minutes for JupyterLab and CodeEditor apps. When set, enables app lifecycle management."
  default     = 60
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
  type        = bool
  description = "Enables the creation of encryption resources"
}


variable "kms_arn" {
  type        = string
  description = "KMS key EFS encryption"
  default     = ""
}

######################################
# VPC
######################################

variable "use_existing_vpc" {
  type        = bool
  description = "Set to true to use an existing VPC instead of creating a new one"
  default     = false
}

variable "existing_vpc_id" {
  type        = string
  description = "ID of existing VPC to use (required if use_existing_vpc is true)"
  default     = ""
}

variable "existing_private_subnet_ids" {
  type        = list(string)
  description = "List of existing private subnet IDs to use (at least one required if use_existing_vpc is true and subnets not auto-discovered)"
  default     = []
}

variable "existing_security_group_id" {
  type        = string
  description = "ID of existing security group to use (optional, will create one if not provided)"
  default     = ""
}

variable "create_security_group_rules" {
  type        = bool
  description = "Set to false if using an existing security group with pre-configured rules"
  default     = true
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for SageMaker VPC (only used when creating new VPC)"
  default     = ""
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values (only used when creating new VPC)"
  default     = []
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values (only used when creating new VPC)"
  default     = []
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones (only used when creating new VPC). If empty, will use first available AZ from data source"
  default     = []
}

variable "enable_dns_support" {
  type        = bool
  description = "Enables DNS Support (only used when creating new VPC)"
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enables DNS Hostnames (only used when creating new VPC)"
  default     = true
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enables creation of Nat Gateway (only used when creating new VPC)"
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  description = "Creates a single one NGW (only used when creating new VPC)"
  default     = true
}

variable "one_ngw_per_az" {
  type        = bool
  description = "Creates only one NGW per AZ (only used when creating new VPC)"
  default     = false
}

variable "enable_vpn_gateway" {
  type        = bool
  description = "Enables creation of VPN Gateway (only used when creating new VPC)"
  default     = false
}