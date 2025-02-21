######################################
# IAM
######################################

output "default_execution_role" {
  value = module.sagemaker_playground.default_execution_role
}

######################################
# SageMaker Domain
######################################

output "sagemaker_domain_id" {
  value = module.sagemaker_playground.sagemaker_domain_id
}

output "sagemaker_domain_arn" {
  value = module.sagemaker_playground.sagemaker_domain_arn
}

######################################
# SageMaker User Profiles
######################################

output "data_scientist_profile_ids" {
  value = module.sagemaker_playground.data_scientist_profile_ids
}


output "ml_engineer_profile_ids" {
  value = module.sagemaker_playground.ml_engineer_profile_ids
}

######################################
# SageMaker Spaces
######################################

output "sagemaker_spaces_id" {
  value = module.sagemaker_playground.sagemaker_spaces_id
}

output "sagemaker_spaces_arn" {
  value = module.sagemaker_playground.sagemaker_spaces_arn
}

######################################
# VPC
######################################

output "vpc_id" {
  value = module.sagemaker_playground.vpc_id
}

output "subnet_ids" {
  value = module.sagemaker_playground.subnet_ids
}

output "security_group_id" {
  value = module.sagemaker_playground.security_group_id
}
