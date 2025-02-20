######################################
# IAM
######################################

output "default_execution_role" {
  value = aws_iam_role.sagemaker_domain_execution_role
  description = "The execution role used for SageMaker Domain"
}

######################################
# SageMaker Domain
######################################

output "sagemaker_domain_id" {
  value = aws_sagemaker_domain.sagemaker_domain.id
  description = "The value of SageMaker domain id"
}

output "sagemaker_domain_arn" {
  value = aws_sagemaker_domain.sagemaker_domain.arn
  description = "Arn of SageMaker domain"
}

######################################
# SageMaker User Profiles
######################################

output "data_scientist_profile_ids" {
  value = { for k, ds in aws_sagemaker_user_profile.data_scientist : k => ds.id }
  description = "Id of SageMaker profiles of Data Scientists"
}

output "ml_engineer_profile_ids" {
  value = { for k, ml in aws_sagemaker_user_profile.ml_engineer : k => ml.id }
  description = "Id of SageMaker profiles of ML Engineers"
}

######################################
# SageMaker Spaces
######################################

output "sagemaker_spaces_id" {
  value = { for k, spaces in aws_sagemaker_space.sagemaker_space : k => spaces.id }
  description = "Id of the Spaces in the SageMaker Domain"
}

output "sagemaker_spaces_arn" {
  value = { for k, spaces in aws_sagemaker_space.sagemaker_space : k => spaces.arn }
  description = "Arn of the Spaces in the SageMaker Domain"
}

######################################
# VPC
######################################

output "vpc_id" {
  value = module.vpc.default_vpc_id
  description = "Id of the VPC"
}

output "subnet_ids" {
  value = module.vpc.private_subnets[*]
  description = "Ids of the Subnets of the VPC"
}

output "security_group_id" {
  value = module.vpc.default_security_group_id
  description = "Ids of the Security Groups in the VPC"
}
