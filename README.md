# Terraform SageMaker Module

This Terraform module creates and manages AWS SageMaker resources necessary to build a SageMaker domain in VPC-only mode with user profiles, private and shared spaces, and different app types within the spaces.

## 📌 Table of Contents

- [Requirements](#requirements)
- [Features](#features)
- [Inputs](#inputs)
  - [Shared Vars](#shared-vars)
  - [SageMaker Domain](#sagemaker-domain)
  - [SageMaker Profiles](#sagemaker-profiles)
  - [SageMaker Shared Spaces](#sagemaker-shared-spaces)
  - [KMS](#kms)
  - [VPC](#vpc)
- [Outputs](#outputs)
  - [SageMaker Domain](#sagemaker-domain-outputs)
  - [SageMaker User Profiles](#sagemaker-user-profiles)
  - [SageMaker Spaces](#sagemaker-spaces)
  - [IAM](#iam)
  - [VPC](#vpc-outputs)
- [Usage Example](#usage-example)
- [License](#license)

---

## 📌 Requirements

- Terraform >= **1.4.0**
- AWS Provider ~> **5.82.2**

## 🚀 Features

- Create a **VPC** for the SageMaker Domain
- Configure **Security Group Rules** for inbound and outbound traffic
- Deploy a **SageMaker Domain** with:
  - Private and Shared Spaces
  - Multiple app types (e.g., Code Editor, Jupyter Notebooks, etc.)
- Define **User Profiles** for Data Scientists and ML Engineers
- Enable **KMS encryption** for enhanced security

---

## ⚙️ Inputs

### 🔹 Shared Vars

| Name          | Description                  | Type     |
|--------------|------------------------------|---------|
| `aws_region` | AWS Region                    | `string` |
| `environment` | Application environment      | `string` |
| `application` | Application name             | `string` |

### 🔹 SageMaker Domain

| Name                       | Description                                       | Type           |
|----------------------------|---------------------------------------------------|---------------|
| `domain_name`              | SageMaker Domain Name                             | `string`      |
| `auth_mode`                | Authentication mode                               | `string`      |
| `allowed_instance_types`   | List of allowed EC2 instance types               | `list(string)` |
| `instance_type`            | Instance type for SageMaker Domain               | `string`      |
| `sagemaker_domain_execution_role` | Execution role for SageMaker Domain  | `string`      |
| `app_network_access_type`  | VPC used for non-EFS traffic                     | `string`      |
| `efs_retention_policy`     | Retention policy for EFS data                    | `string`      |
| `enable_docker`            | Enables Local Mode and Docker Access             | `string`      |
| `canvas_use`               | Enables SageMaker Canvas resources               | `bool`        |
| `jupyter_image_tag`        | Jupyter Image Tag                                | `string`      |
| `sagemaker_image_arn_prefix` | SageMaker Image ARN prefix                     | `string`      |

### 🔹 SageMaker Profiles

| Name        | Description                                       | Type          |
|------------|---------------------------------------------------|--------------|
| `sm_settings` | SageMaker profiles and Private Spaces to create | `map(object)` |

### 🔹 SageMaker Shared Spaces

| Name         | Description                            | Type          |
|-------------|--------------------------------------|--------------|
| `shared_spaces` | Shared Spaces for the domain       | `map(object)` |

### 🔹 KMS

| Name           | Description                          | Type    |
|---------------|----------------------------------|--------|
| `kms_encryption` | Enables encryption resources  | `bool`  |
| `kms_arn`       | KMS key for EFS encryption    | `string` |

### 🔹 VPC

| Name                    | Description                                 | Type          |
|-------------------------|---------------------------------------------|--------------|
| `cidr_block`            | CIDR block for SageMaker VPC               | `string`     |
| `private_subnet_cidrs`  | Private Subnet CIDR values                 | `list(string)` |
| `public_subnet_cidrs`   | Public Subnet CIDR values                  | `list(string)` |
| `azs`                   | Availability Zones                          | `list(string)` |
| `enable_dns_support`    | Enables DNS Support                        | `bool`       |
| `enable_dns_hostnames`  | Enables DNS Hostnames                      | `bool`       |
| `enable_nat_gateway`    | Enables NAT Gateway                        | `bool`       |
| `single_nat_gateway`    | Creates a single NGW                       | `bool`       |
| `one_ngw_per_az`        | Creates one NGW per AZ                     | `bool`       |
| `enable_vpn_gateway`    | Enables VPN Gateway                        | `bool`       |

---

## 📤 Outputs

### 🔹 SageMaker Domain Outputs

| Name                  | Description                        |
|----------------------|--------------------------------|
| `sagemaker_domain_id`  | SageMaker domain ID             |
| `sagemaker_domain_arn` | ARN of the SageMaker domain     |

### 🔹 SageMaker User Profiles

| Name                        | Description                                   |
|-----------------------------|-----------------------------------------------|
| `data_scientist_profile_ids` | IDs of Data Scientist profiles                |
| `ml_engineer_profile_ids`   | IDs of ML Engineer profiles                   |

### 🔹 SageMaker Spaces

| Name                   | Description                                   |
|-----------------------|-------------------------------------------|
| `sagemaker_spaces_id`  | IDs of the Spaces in the SageMaker Domain  |
| `sagemaker_spaces_arn` | ARNs of the Spaces in the SageMaker Domain |

### 🔹 IAM

| Name                  | Description                                  |
|----------------------|------------------------------------------|
| `default_execution_role` | Execution role used for SageMaker Domain  |

### 🔹 VPC Outputs

| Name                 | Description                              |
|---------------------|--------------------------------------|
| `vpc_id`            | ID of the VPC                          |
| `subnet_ids`        | IDs of the Subnets in the VPC         |
| `security_group_id` | IDs of the Security Groups in the VPC |

---

## 🚀 Usage Example

```hcl
module "sagemaker" {
  source = "epsilonline/sagemaker-playground/aws"
  version = "~>1.0.0"

  #Shared Vars
  aws_region = "eu-west-1"
  environment = "dev"
  application = "TestSMPlayGround"
  #SageMaker Domain
  domain_name = "TestPlayGround"
  auth_mode = "IAM"
  instance_type = "system"
  sagemaker_domain_execution_role = "TestSMDomainExecutionRole"
  app_network_access_type = "VpcOnly"
  efs_retention_policy = "Retain"
  enable_docker = "ENABLED"
  canvas_use = true
  jupyter_image_tag = "jupyter-server-3"
  sagemaker_image_arn_prefix = "arn:aws:sagemaker:eu-west-1:470317259841:image"
  #SageMaker Profiles and Spaces
  sm_settings = {
      "TestUser" = {
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
      }
    }

  shared_spaces = {
    "TestUser" = {
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
  #KMS
  kms_encryption = false
  kms_arn = ""
  #VPC
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
}
```

---

## 📜 License

This project is licensed under the [**LGPL-3 License**](https://www.gnu.org/licenses/lgpl-3.0.html#license-text).