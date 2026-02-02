# Terraform SageMaker Module

This Terraform module creates and manages AWS SageMaker resources necessary to build a SageMaker domain in VPC-only mode with user profiles, private and shared spaces, and different app types within the spaces.

## 📌 Table of Contents

- [Quick Start](#-quick-start)
- [Important Security Notes](#-important-security-notes)
- [Prerequisites](#prerequisites)
- [Requirements](#requirements)
- [Features](#features)
- [Inputs](#inputs)
  - [Shared Vars](#shared-vars)
  - [SageMaker Domain](#sagemaker-domain)
  - [SageMaker Profiles](#sagemaker-profiles)
  - [SageMaker Shared Spaces](#sagemaker-shared-spaces)
  - [KMS](#kms)
  - [VPC](#vpc)
  - [EMR Serverless](#emr-serverless)
- [Outputs](#outputs)
  - [SageMaker Domain](#sagemaker-domain-outputs)
  - [SageMaker User Profiles](#sagemaker-user-profiles)
  - [SageMaker Spaces](#sagemaker-spaces)
  - [IAM](#iam)
  - [VPC](#vpc-outputs)
- [Backend Configuration](#backend-configuration)
- [Usage Examples](#-usage-examples)
- [License](#license)

---

## ⚡ Quick Start

Get up and running with a minimal SageMaker domain in under 5 minutes:

```hcl
module "sagemaker" {
  source  = "epsilonline/sagemaker-playground/aws"
  version = "~>1.0.0"

  # Basic Configuration
  aws_region  = "eu-west-1"
  environment = "dev"
  application = "my-sagemaker"
  domain_name = "my-domain"

  # Domain Settings
  auth_mode                       = "IAM"
  instance_type                   = "system"
  sagemaker_domain_execution_role = "MySageMakerRole"
  app_network_access_type         = "VpcOnly"
  jupyter_image_tag               = "jupyter-server-3"
  sagemaker_image_arn_prefix      = "arn:aws:sagemaker:eu-west-1:470317259841:image"

  # User Profile with Code Editor
  sm_settings = {
    "DataScientist1" = {
      role = "DataScientist"
      spaces = {
        "CodeEditor" = {
          app_type      = "CodeEditor"
          app_name      = "default"
          instance_type = "ml.t3.medium"
          image_arn     = "arn:aws:sagemaker:eu-west-1:819792524951:image/sagemaker-distribution-gpu"
        }
      }
    }
  }

  # VPC Configuration (creates new VPC)
  cidr_block           = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
  azs                  = ["eu-west-1a", "eu-west-1b"]

  # Optional Features
  canvas_use     = false
  kms_encryption = false
  shared_spaces  = {}
}
```

**Deploy in 3 steps:**

```bash
# 1. Initialize Terraform
terraform init

# 2. Review the plan
terraform plan

# 3. Apply the configuration
terraform apply
```

> [!TIP]
> For production use with an existing VPC, see the [Usage Examples](#-usage-examples) section below.

---

## ⚠️ Important Security Notes

This module includes several experimental features and configuration options that provide broad permissions for development and testing purposes. **These features are NOT recommended for production environments** without careful security review.

> [!CAUTION]
> **Experimental Features with Wide Permissions:**
> 
> The following configurations grant elevated permissions and should be used with caution:
> 
> - **`enable_docker = "ENABLED"`** - Grants container-level access and Docker daemon permissions, allowing users to run arbitrary containers. This can be a security risk in multi-tenant environments.
> 
> - **`eneable_emr_capabilities_policy = true`** - Provides full EMR cluster and EMR Serverless administrative access, including create, modify, and terminate permissions for all EMR resources.
> 
> - **`PowerUserAccess` Policy** - Used by the ML Engineer role, this AWS managed policy grants broad permissions across AWS services (almost administrator-level access excluding IAM).
> 
> - **`app_network_access_type = "PublicInternetOnly"`** - While available as an option, this bypasses VPC security controls and is not recommended for production workloads handling sensitive data.

> [!WARNING]
> **Production Deployment Recommendations:**
> 
> For production environments, we strongly recommend:
> 
> 1. **Use VPC-Only Mode**: Set `app_network_access_type = "VpcOnly"` to ensure all traffic flows through your VPC
> 2. **Disable Docker**: Set `enable_docker = "DISABLED"` unless absolutely required and properly secured
> 3. **Limit EMR Permissions**: Set `eneable_emr_capabilities_policy = false` and grant only specific EMR permissions as needed
> 4. **Enable KMS Encryption**: Set `kms_encryption = true` to encrypt data at rest
> 5. **Use Custom IAM Policies**: Replace broad AWS managed policies (like `PowerUserAccess`) with least-privilege custom policies
> 6. **Enable MFA**: Implement multi-factor authentication for all user access
> 7. **Regular Security Audits**: Review IAM policies, security group rules, and access patterns regularly
> 8. **Network Segmentation**: Use dedicated VPCs with private subnets and VPC endpoints

> [!NOTE]
> **Development vs. Production:**
> 
> This module is designed to be flexible for both development/testing and production use cases:
> 
> - **Development/Testing**: Experimental features enable rapid prototyping and learning
> - **Production**: Disable experimental features and follow the security hardening recommendations above
> 
> Always perform a thorough security review and adjust IAM policies, network configurations, and encryption settings based on your organization's security requirements and compliance needs.

---

## 📋 Prerequisites

Before using this module, ensure the following AWS IAM policies exist in your AWS account:

### Required AWS Managed Policies
- **`DataScientist`** - Used by the Data Scientist role created by this module
- **`PowerUserAccess`** - Used by the ML Engineer role created by this module
- **`AmazonSageMakerFullAccess`** - Attached to the SageMaker domain execution role
- **`AmazonSageMakerCanvasFullAccess`** - Required if `canvas_use = true`
- **`AmazonSageMakerCanvasAIServicesAccess`** - Required if `canvas_use = true`

### AWS Permissions Required
The user or role executing this Terraform configuration must have permissions to:
- Create and manage IAM roles and policies
- Create and manage VPC resources (if creating a new VPC)
- Create and manage SageMaker domains, user profiles, spaces, and apps
- Create and manage KMS keys (if `kms_encryption = true`)
- Create and manage security groups

> [!IMPORTANT]
> If the `DataScientist` or `PowerUserAccess` policies don't exist in your AWS account, you'll need to create them or modify the module to use alternative IAM policies.

---

## 📌 Requirements

- Terraform >= **1.4.0**
- AWS Provider ~> **5.82.2**

## 🚀 Features

This module provides a comprehensive, production-ready SageMaker infrastructure with the following capabilities:

### 🏗️ **Flexible Infrastructure**
- **VPC Management**: Create a new VPC with public/private subnets or integrate with existing VPC infrastructure
- **Multi-AZ Support**: Deploy across multiple availability zones for high availability
- **Intelligent Subnet Detection**: Automatically discovers and configures private subnets
- **Security Group Management**: Pre-configured security rules or bring your own

### 🎯 **SageMaker Domain Configuration**
- **VPC-Only Mode**: Secure, isolated SageMaker environments
- **Flexible Authentication**: Support for IAM and SSO authentication modes
- **Private Spaces**: Dedicated development environments per user profile
- **Shared Spaces**: Collaborative environments for team-based workflows
- **Multiple App Types**: Support for JupyterLab, Code Editor, MLflow, and custom applications
- **Lifecycle Management**: Automatic shutdown of idle applications to reduce costs
- **Docker Support**: Enable local mode and Docker access for containerized workloads
- **SageMaker Canvas**: Optional integration for no-code ML model building

### 👥 **User & Role Management**
- **Pre-configured Roles**: Data Scientist and ML Engineer roles with appropriate permissions
- **Custom Image Support**: Use custom Docker images for Jupyter and Code Editor environments
- **Per-User Spaces**: Isolated development environments with customizable instance types
- **Execution Roles**: Automatically managed IAM roles with least-privilege access

### 🔐 **Security & Compliance**
- **KMS Encryption**: Optional encryption for EFS volumes and data at rest
- **VPC-Only Access**: Prevent public internet access to notebooks
- **IAM Integration**: Fine-grained access control with AWS IAM policies
- **EFS Retention Policies**: Configurable data retention (Retain/Delete)

### ⚡ **EMR Serverless Integration**
- **S3 Runtime Role**: Dedicated role for EMR Serverless applications with S3 access
- **Admin Permissions**: Optional full EMR access for Data Scientists
- **Automatic Tagging**: EMR applications tagged with SageMaker domain/user/space metadata
- **Seamless Integration**: Run Spark jobs directly from SageMaker notebooks

### 🎨 **Customization Options**
- **Custom Instance Types**: Choose from a wide range of ML-optimized instances
- **Custom Images**: Use SageMaker-managed or custom Docker images
- **Idle Timeout**: Configure automatic shutdown for cost optimization
- **Environment Variables**: Pass custom configuration to applications
- **Resource Tagging**: Automatic tagging for cost allocation and governance

---

## ⚙️ Inputs

### 🔹 Shared Vars

| Name          | Description                  | Type     |
|--------------|------------------------------|---------|
| `aws_region` | AWS Region                    | `string` |
| `environment` | Application environment      | `string` |
| `application` | Application name             | `string` |

### 🔹 SageMaker Domain

| Name                       | Description                                       | Type           | Default |
|----------------------------|---------------------------------------------------|---------------|---------|
| `domain_name`              | SageMaker Domain Name                             | `string`      | -       |
| `auth_mode`                | Authentication mode (IAM or SSO)                  | `string`      | `""`    |
| `instance_type`            | Default instance type for Jupyter Server apps (e.g., `system`, `ml.t3.medium`) | `string`      | -       |
| `sagemaker_domain_execution_role` | Execution role for SageMaker Domain  | `string`      | -       |
| `app_network_access_type`  | VPC used for non-EFS traffic (`VpcOnly` or `PublicInternetOnly`) | `string` | `""` |
| `efs_retention_policy`     | Retention policy for EFS data (`Retain` or `Delete`) | `string`      | `""`    |
| `enable_docker`            | Enables Local Mode and Docker Access (`ENABLED` or `DISABLED`) | `string` | `"DISABLED"` |
| `canvas_use`               | Enables SageMaker Canvas resources               | `bool`        | -       |
| `jupyter_image_tag`        | Jupyter Image Tag                                | `string`      | -       |
| `sagemaker_image_arn_prefix` | SageMaker Image ARN prefix                     | `string`      | -       |
| `default_idle_timeout_in_minutes` | Idle timeout for JupyterLab and CodeEditor apps (enables lifecycle management) | `number` | `60` |

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

| Name                           | Description                                                | Type          | Default |
|--------------------------------|------------------------------------------------------------|---------------|---------|
| `existing_vpc_id`              | ID of existing VPC (when provided, uses existing VPC instead of creating new) | `string` | `""` |
| `existing_private_subnet_ids`  | List of existing private subnet IDs (recommended when using existing VPC) | `list(string)` | `[]` |
| `existing_security_group_id`   | ID of existing security group (optional)                   | `string`      | `""`    |
| `create_security_group_rules`  | Create security group rules (set false if pre-configured)  | `bool`        | `true`  |
| `cidr_block`                   | CIDR block for new VPC                                     | `string`      | `""`    |
| `private_subnet_cidrs`         | Private Subnet CIDR values for new VPC                     | `list(string)`| `[]`    |
| `public_subnet_cidrs`          | Public Subnet CIDR values for new VPC                      | `list(string)`| `[]`    |
| `azs`                          | Availability Zones for new VPC                             | `list(string)`| `[]`    |
| `enable_dns_support`           | Enables DNS Support for new VPC                            | `bool`        | `true`  |
| `enable_dns_hostnames`         | Enables DNS Hostnames for new VPC                          | `bool`        | `true`  |
| `enable_nat_gateway`           | Enables NAT Gateway for new VPC                            | `bool`        | `true`  |
| `single_nat_gateway`           | Creates a single NGW for new VPC                           | `bool`        | `true`  |
| `one_ngw_per_az`               | Creates one NGW per AZ for new VPC                         | `bool`        | `false` |
| `enable_vpn_gateway`           | Enables VPN Gateway for new VPC                            | `bool`        | `false` |

### 🔹 EMR Serverless

| Name                 | Description                                                      | Type     | Default |
|---------------------|------------------------------------------------------------------|----------|---------|
| `emr_s3_bucket_name` | S3 bucket name for EMR Serverless runtime access (creates S3 runtime role when provided) | `string` | `""` |
| `eneable_emr_capabilities_policy`          | Enables EMR admin permissions for DataScientist role             | `bool`   | `false` |

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

| Name                     | Description                                  |
|-------------------------|----------------------------------------------|
| `default_execution_role` | Execution role used for SageMaker Domain     |
| `emr_runtime_role`       | EMR Serverless S3 runtime role (if configured)|

### 🔹 VPC Outputs

| Name                 | Description                              |
|---------------------|--------------------------------------|
| `vpc_id`            | ID of the VPC                          |
| `subnet_ids`        | IDs of the Subnets in the VPC         |
| `security_group_id` | IDs of the Security Groups in the VPC |

---

## 🔧 Backend Configuration

For production use, it's recommended to configure a remote backend to store Terraform state securely.

### S3 Backend with DynamoDB Locking

Create a `backend.tf` file in your Terraform configuration:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "sagemaker/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### Initialize Backend

After configuring the backend, initialize Terraform:

```bash
terraform init
```

> [!TIP]
> Create the S3 bucket and DynamoDB table before running `terraform init`. The DynamoDB table should have a partition key named `LockID` (String).

## � Usage Examples

### Using a New VPC (Default)

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

### Using an Existing VPC

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
        }
      }
  }
  
  shared_spaces = {}
  
  #KMS
  kms_encryption = false
  kms_arn = ""
  
  #Use Existing VPC - simply provide existing_vpc_id to use an existing VPC
  existing_vpc_id = "vpc-0123456789abcdef0"
  existing_private_subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  existing_security_group_id = "sg-0123456789abcdef0"  # Optional - will create one if not provided
}
```

**Notes for Using an Existing VPC:**

1. **Required Variables:**
   - Provide your `existing_vpc_id` - this automatically enables existing VPC mode
   - Provide `existing_private_subnet_ids` (recommended) or ensure subnets are discoverable

2. **Optional Variables:**
   - `existing_security_group_id` - If not provided, a new security group will be created
   - `create_security_group_rules` - Set to `false` if your existing security group already has the required rules configured

3. **Security Requirements:**
   - Your VPC must have DNS support and DNS hostnames enabled
   - Private subnets must have internet access (via NAT Gateway) or use VPC endpoints
   - Security group must allow:
     - Egress: All traffic to 0.0.0.0/0
     - Ingress: TCP 8192-65535 from VPC CIDR (for Jupyter)
     - Ingress: TCP 22 from VPC CIDR (for Git)

4. **Best Practices:**
   - Use multiple private subnets across different AZs for high availability
   - Ensure subnets have adequate IP address space for SageMaker resources
   - When `existing_vpc_id` is empty (default), a new VPC is created using the VPC-related variables (`cidr_block`, `azs`, etc.)

### Enabling EMR Serverless Integration

To enable EMR Serverless integration with your SageMaker domain, add the following variables to your module configuration:

```hcl
module "sagemaker" {
  # ... other configuration ...
  
  # EMR Serverless Configuration
  emr_s3_bucket_name = "my-emr-serverless-bucket"  # S3 bucket for EMR Serverless runtime
  eneable_emr_capabilities_policy          = true                         # Enables EMR admin permissions for DataScientist role
}
```

**EMR Configuration Notes:**

1. **EMR S3 Bucket** (`emr_s3_bucket_name`):
   - When provided, creates an `EMRServerlessS3RuntimeRole` with access to the specified S3 bucket
   - This role is used by EMR Serverless applications for reading/writing data
   - Leave empty if EMR Serverless S3 access is not needed

2. **EMR Admin Permissions** (`eneable_emr_capabilities_policy`):
   - When set to `true`, attaches the `EMRAdminPolicy` to the DataScientist role
   - Grants full access to EMR clusters and EMR Serverless applications
   - Includes permissions for creating, managing, and terminating EMR resources
   - Automatically tags EMR Serverless applications with SageMaker domain, user profile, and space ARNs
   - Set to `false` (default) if EMR access is not required

---

## 📜 License

This project is licensed under the **GNU Lesser General Public License v3.0 (LGPL-3.0)**.

```text
Copyright (C) 2024 Epsilon Line

This library is free software; you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation; either version 3 of the License, or (at your option) any
later version.
```

For full license details, see the [LGPL-3.0 License](https://www.gnu.org/licenses/lgpl-3.0.html#license-text).

---

**Made with ❤️ by the Epsilon Cloud Team**