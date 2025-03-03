
######################################
# Shared vars
######################################

aws_region = "eu-west-1"

environment = "dev"

application = "TestSMPlayGround"

######################################
# SageMaker Domain
######################################

domain_name = "TestPlayGround"

auth_mode = "IAM"

allowed_instance_types = [""]

instance_type = "system"

sagemaker_domain_execution_role = "TestSMDomainExecutionRole"

app_network_access_type = "VpcOnly"

efs_retention_policy = "Retain"

enable_docker = "ENABLED"

canvas_use = true

jupyter_image_tag = "jupyter-server-3"

sagemaker_image_arn_prefix = "arn:aws:sagemaker:eu-west-1:470317259841:image"

######################################
# SageMaker Profiles
######################################

sm_settings = {
    "User1Test" = {
      role = "DataScientist"
      spaces = {
         "CodeEditor" = {
            app_type                = "CodeEditor"
            app_name                = "default"
            instance_type           = "ml.c5.xlarge"
            image_arn               = "arn:aws:sagemaker:eu-west-1:819792524951:image/sagemaker-distribution-gpu"
            idle_timeout_in_minutes = null
         }              
         "JupyterLab" = {
            app_type                = "JupyterLab"
            app_name                = "default"
            instance_type           = "ml.c5.xlarge"
            image_arn               = ""
            idle_timeout_in_minutes = null
         }
      }
    },
    "User2Test" = {
      role = "MLEngineer"
      spaces = {            
         "JupyterLab" = {
            app_type                = "JupyterLab"
            app_name                = "default"
            instance_type           = "ml.c5.xlarge"
            image_arn               = ""
            idle_timeout_in_minutes = null
         }
      }
    }
}

shared_spaces = {
   "User1Test" = {
      spaces = {
         "SharedJupyterLab" =  {
            app_type = "JupyterLab"
            app_name = "JupyterLab"
            instance_type = "ml.c5.xlarge"
            image_arn = ""    
            idle_timeout_in_minutes = null
         }
      }
   }
}

######################################
# MLFlow
######################################

create_tracking_server = false

tracking_server_name = "playground_server"

artifact_store_uri = ""

######################################
# KMS
######################################

kms_encryption = false

kms_arn = ""

######################################
# VPC
######################################

cidr_block     = "10.0.0.0/16"

private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

enable_dns_support   = true
enable_dns_hostnames = true
enable_nat_gateway = true
single_nat_gateway = true
one_ngw_per_az = false
enable_vpn_gateway = false